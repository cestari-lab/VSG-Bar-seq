#!/bin/bash

sampledir=$1            # Path to directory of input and output files, subfolders will be created here for output files
data=$2                 # Path or name of input folder containg fastq data
barcode="$3"/*.txt      # Path to .txt file containing the barcodes, note each barcode (6 or 8 bp) should be in a separate
genome=$4               # Path to genome file to use as a reference during mapping with minimap2
gtf=$5                  # Path to .gtf file for assinging features by featureCounts
threads=$6              # Number of threads to use for minimap2 alignment and featureCounts from package subread

#START with splitseq script
echo processing ... spliting fastq according to barcodes

# CREATE DIRECTORIES for splitseq.
mkdir -p "${sampledir}/result_split_fastq/"
splitfq="${sampledir}/result_split_fastq"

# create a folder for output
for line in `cat $barcode`
do rcgrep --grepargs "-A 2 -B 1 --no-group-separator" \
 --query "$line" $data/*.fastq > $splitfq/"$line".fastq
done

echo processing ...creating split_summary.txt file

#create a summary file
echo "Number of matched reads per barcode" > $splitfq/split_summary.txt

#code for counting number of fastq splitted
for file in $splitfq/*.fastq
do grep -cH "runid" $file >> $splitfq/split_summary.txt
done

#code for calculating total number of fastq files in input files and those with barcodes
echo "Total number of reads searched" >> $splitfq/split_summary.txt
grep "runid" $data/*.fastq | wc -l >> $splitfq/split_summary.txt

echo "Total number of reads with barcodes" >> $splitfq/split_summary.txt
cut -f2 -d ':' -s $splitfq/split_summary.txt | paste -sd+ | bc -l >> $splitfq/split_summary.txt

echo processing ... spliting fastq according to barcodes ... complete

# For the next steps packages required are: minimap2, samtools, subread
echo starting minimap, samtools, subread

#CREATE DIRECTORIES
mkdir -p "${sampledir}/result_mapcount/sam"
mkdir -p "${sampledir}/result_mapcount/bam"
mkdir -p "${sampledir}/result_mapcount/sorted_bam"
mkdir -p "${sampledir}/result_mapcount/counts"
mkdir -p "${sampledir}/result_mapcount/counts/input"
mkdir -p "${sampledir}/result_mapcount/topmap"

#INPUT code
for fq in $splitfq/*.fastq
    do
    echo "working with file $fq"

    base=$(basename $fq .fastq)
    echo "base name is $base"

# INPUT are splitted fastq files
fq=$splitfq/${base}.fastq

sam="${sampledir}/result_mapcount/sam/${base}.sam"
bam="${sampledir}/result_mapcount/bam/${base}.bam"
sorted_bam="${sampledir}/result_mapcount/sorted_bam/${base}_sorted.bam"
count="${sampledir}/result_mapcount/counts/${base}.txt"
count_input="${sampledir}/result_mapcount/counts/input"
topmap="${sampledir}/result_mapcount/topmap"

# COMMAND
echo processing ... mapping data to genome with minimap2
minimap2 -ax map-ont -t $threads -2 $genome $fq > $sam
echo processing ... mapping data to genome with minimap2...complete

echo processing ... sorting, filtering, indexing with samtools
samtools view -S -b -q 20 -F 2304 -@ $threads $sam > $bam
samtools sort -@ $threads $bam > $sorted_bam
samtools index -@ $threads $sorted_bam
echo processing ... sorting, filtering, indexing with samtools...complete

echo processing ... counting reads per feature with featureCounts
featureCounts -LO -a $gtf \
-o $count -F "GTF" -t "exon" -g "gene_id" --readExtension3 200 --fraction --primary -T $threads $sorted_bam
done
echo processing ... counting reads per feature with featureCounts...complete

echo processing ... selecting top mapped reads
# Counting topmapped reads

cp "${sampledir}/result_mapcount/counts"/*.txt $count_input

for files in $count_input/*.txt
do
  if [ -f "$files" ] #check if it's a regular file
  then
    line=$(cat $files | sort -nk7 | tail -1) #brings the topmapped feature
    echo -e "${line}\t${files}" >> $topmap/topmapped.txt #concatenates the line with the file name
  fi
done


echo processing ... complete.

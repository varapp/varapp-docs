#!/bin/bash
# v.1 March 17, 2016
#Sylvain Pradervand

# Set up environment
SCRIPT_PATH=$(cd $(dirname $0) && pwd)
source $SCRIPT_PATH/vcf_annotation_config.txt

TABIX_PATH=$TOOL_PATH/$TABIX
VT_PATH=$TOOL_PATH/$VT
VEP_PATH=$TOOL_PATH/$VEP
GEMINI_PATH=$TOOL_PATH/$GEMINI
VCFTOOL_PATH=$TOOL_PATH/$VCFTOOL
WORKING_DIR=/scratch/local/weekly

export PATH=$PATH:$TABIX_PATH
export PATH=$PATH:$VT_PATH
export PATH=$PATH:$VEP_PATH
export PATH=$PATH:$GEMINI_PATH
export PATH=$PATH:$VCFTOOL_PATH
export PERL5LIB=$TOOL_PATH/$VCFTOOL_PERL

###############################################################
# START MAIN
###############################################################
if [ $# -lt 2 ]; then
  echo "Usage: $0 input_vcffile reference_genome ped_file (optional)"
  exit 1
fi

input=$1
ref=$2
ped=$3
prefix=${input%.*}
name=${prefix##*/}

#copy files to /scratch/local/weekly
####################################
WORKING_DIR=$WORKING_DIR"/"$name
mkdir -p -m 770 $WORKING_DIR
prefix=$WORKING_DIR/$name

#print tools and version
date_str=`date +"%y-%m-%d"`
log_file=$prefix"."$date_str".log"
echo "==== VCF annotation pipeline ====" `date` > $log_file
echo $VT_PATH >> $log_file
echo $VEP_PATH >> $log_file
echo $VCFTOOL_PATH >> $log_file
gemini -v 2>> $log_file

# VT
###############################################################
echo "==== VT decompose and normalize ====" `date` >> $log_file
vcf_dec=${prefix}.de.vcf
vcf_vt=${prefix}.vt.vcf
vt decompose -s $input > $vcf_dec 2>> $log_file
vt normalize -r $ref $vcf_dec > $vcf_vt 2>> $log_file
rm -f $vcf_dec

#VEP
###############################################################
echo "==== VEP annotation ====" `date` >> $log_file
vep_out=${prefix}.vep.vcf
#Don't repeat VEP annotation if crash during gemini loading
if [ ! -s $vep_out ]; then
   perl ${VEP_PATH}/variant_effect_predictor.pl -i $vcf_vt \
        --cache \
        --dir ${VEP_PATH}/.vepcache \
        --fasta $ref \
        --sift b \
        --polyphen b \
        --symbol \
        --numbers \
        --biotype \
        --total_length \
        --canonical --ccds \
        -o $vep_out \
        --vcf \
        --hgvs \
        --gene_phenotype \
        --uniprot \
        --force_overwrite \
        --port 3337 \
        --domains --regulatory \
        --protein --tsl \
        --variant_class >> $log_file 2>&1
fi

#Gemini
###############################################################
#gz and tabix
bgzip -c $vep_out > ${vep_out}.gz
tabix -p vcf ${vep_out}.gz
# load the pre-processed VCF into GEMINI
#--save-info-string
gemini_db=${prefix}.${GEMINI_DB_SUFFIX}
if [ ! -s $gemini_db ]; then
	echo "==== Load VCF into GEMINI ====" `date` >> $log_file
	cmd="gemini load --cores "$CPU_NB" -t VEP -v "${vep_out}.gz
	if [ $ped ] && [ -s $ped ];then
		cmd=$cmd" -p "$ped
	fi
	cmd=$cmd" "$gemini_db" >> "$log_file" 2>&1"
	echo $cmd >> $log_file
	eval $cmd
fi
#Extract Info field from VCF
echo "==== Add custom annotation from VCF INFO field into GEMINI ====" `date` >> $log_file
gemini annotate -f ${vep_out}.gz \
                  -a extract \
                  -c AF,BaseQRankSum,FS,MQRankSum,ReadPosRankSum,SOR \
                  -t float,float,float,float,float,float \
                  -e AF,BaseQRankSum,FS,MQRankSum,ReadPosRankSum,SOR \
                  -o mean,mean,mean,mean,mean,mean \
                  $gemini_db >> $log_file 2>&1

if [ -s $gemini_db ]; then
	echo "==== Copy files to output dir ====" `date` >> $log_file
	cp $gemini_db $VCF_DIR
	cp ${prefix}.*.log $VCF_DIR
	cp ${prefix}.vt.vcf $VCF_DIR
	echo "==== VCF annotation pipeline finished ====" `date` >> $log_file
else 
	echo "==== VCF annotation pipeline did not finished==== "`date` >> $log_file
fi
exit 0




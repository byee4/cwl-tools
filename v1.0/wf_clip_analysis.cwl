#!/usr/bin/env cwltool

doc: |
  The main workflow that produces two reproducible peaks via IDR given
  two eCLIP samples (1 input, 1 IP each).

cwlVersion: v1.0
class: Workflow


requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement


inputs:


  ### ANNOTATOR INPUTS ###


  species:
    type: string
  peak_file:
    type: File
  gtfdb_file:
    type: File


  ### REQUIRED REPEAT MAPPING INPUTS ###

  dataset:
    type: string

  barcode1r1FastqGz:
    type: File
  barcode1r2FastqGz:
    type: File
  barcode1rmRepBam:
    type: File

  barcode2r1FastqGz:
    type: File
  barcode2r2FastqGz:
    type: File
  barcode2rmRepBam:
    type: File

  barcode1Inputr1FastqGz:
    type: File
  barcode1Inputr2FastqGz:
    type: File
  barcode1InputrmRepBam:
    type: File

  bowtie2_db:
    type: Directory
  bowtie2_prefix:
    type: string
  fileListFile1:
    type: File
  fileListFile2:
    type: File

  gencodeGTF:
    type: File
  gencodeTableBrowser:
    type: File
  repMaskBEDFile:
    type: File


  ### REGION LEVEL ENRICHMENT INPUTS ###


  clip_bam_file:
    type: File
  input_bam_file:
    type: File


  ### MOTIF ANALYSIS INPUTS ###

  k:
    type: int
    default: 6
  nrand:
    type: int
    default: 3
  genome_fasta:
    type: File

outputs:


  ### ANNOTATED OUTPUTS ###


  output_annotated_file:
    type: File
    outputSource: step_annotate_peaks/output_file


  ### REPEAT MAPPING OUTPUTS ###


  output_repeat_ip_parsed_file:
    type: File
    outputSource: step_repeat_mapping/output_ip_parsed

  output_repeat_input_parsed_file:
    type: File
    outputSource: step_repeat_mapping/output_input_parsed

  output_ip_concatenated_pre_rmDup_sam_file:
    type: File
    outputSource: step_repeat_mapping/output_ip_concatenated_pre_rmDup_sam_file

  output_input_concatenated_pre_rmDup_sam_file:
    type: File
    outputSource: step_repeat_mapping/output_input_concatenated_pre_rmDup_sam_file

  output_ip_concatenated_rmDup_sam_file:
    type: File
    outputSource: step_repeat_mapping/output_ip_concatenated_rmDup_sam_file

  output_input_concatenated_rmDup_sam_file:
    type: File
    outputSource: step_repeat_mapping/output_input_concatenated_rmDup_sam_file


  ### REGION LEVEL ENRICHMENT OUTPUTS ###


  output_clip_broad_feature_counts_file:
    type: File
    outputSource: step_region_level_enrichment/clipBroadFeatureCountsFile

  output_input_broad_feature_counts_file:
    type: File
    outputSource: step_region_level_enrichment/inputBroadFeatureCountsFile

  output_l2fc_with_pval_enr_file:
    type: File
    outputSource: step_region_level_enrichment/l2fcWithPvalEnrFile


  ### MOTIF ANALYSIS OUTPUTS ###


  output_pickle_file:
    type: File
    outputSource: step_motif_analysis/output_pickle_file

  output_homer_dir:
    type: Directory
    outputSource: step_motif_analysis/output_homer_dir

  output_homer_svg_file:
    type: File
    outputSource: step_motif_analysis/output_file


steps:

  step_annotate_peaks:
    run: annotator/annotator.cwl
    in:
      input: peak_file
      gtfdb: gtfdb_file
      species: species
    out:
      - output_file

  step_repeat_mapping:
    doc: |
      performs repeat mapping
    run: repetitive-element-mapping/wf_ecliprepmap_pe.cwl
    in:
      dataset: dataset
      barcode1r1FastqGz: barcode1r1FastqGz
      barcode1r2FastqGz: barcode1r2FastqGz
      barcode1rmRepBam: barcode1rmRepBam
      barcode2r1FastqGz: barcode2r1FastqGz
      barcode2r2FastqGz: barcode2r2FastqGz
      barcode2rmRepBam: barcode2rmRepBam
      barcode1Inputr1FastqGz: barcode1Inputr1FastqGz
      barcode1Inputr2FastqGz: barcode1Inputr2FastqGz
      barcode1InputrmRepBam: barcode1InputrmRepBam
      bowtie2_db: bowtie2_db
      bowtie2_prefix: bowtie2_prefix
      fileListFile1: fileListFile1
      fileListFile2: fileListFile2
      gencodeGTF: gencodeGTF
      gencodeTableBrowser: gencodeTableBrowser
      repMaskBEDFile: repMaskBEDFile
    out:
      - output_barcode1_concatenated_pre_rmDup_sam_file
      - output_barcode2_concatenated_pre_rmDup_sam_file
      - output_ip_concatenated_pre_rmDup_sam_file
      - output_input_concatenated_pre_rmDup_sam_file
      - output_barcode1_concatenated_rmDup_sam_file
      - output_barcode2_concatenated_rmDup_sam_file
      - output_ip_concatenated_rmDup_sam_file
      - output_input_concatenated_rmDup_sam_file
      - output_ip_parsed
      - output_input_parsed

  step_region_level_enrichment:
    doc: |
      performs region level enrichment for each gene
    run: region_based_CLIP_enrichment/wf_region_based_enrichment.cwl
    in:
      clipBamFile: clip_bam_file
      inputBamFile: input_bam_file
      gencodeGTFFile: gencodeGTF
      gencodeTableBrowserFile: gencodeTableBrowser
    out:
      - clipBroadFeatureCountsFile
      - inputBroadFeatureCountsFile
      - combinedOutputFile
      - l2fcWithPvalEnrFile
      - l2fcFile

  step_motif_analysis:
    doc: |
      runs analyze_motifs and gets kmer and HOMER results.
    run: clip_analysis_legacy/analyze_motifs.cwl
    in:
      peaks: peak_file
      species: species
      k: k
      nrand: nrand
      genome_fasta: genome_fasta
    out:
      - output_pickle_file
      - output_homer_dir
      - output_file


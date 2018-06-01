#!/usr/bin/env cwltool

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement

inputs:

  aggr_nickname:
    type: string
  aggr_norm_method:
    type: string
    default: "mapped"
  assay_protocol:
    type: string
  contact_email:
    type: string
  experiment_nickname:
    type: string
  experiment_start_date:
    type: string
  experiment_summary:
    type: string
  extract_protocol_description:
    type: string
  growth_protocol_description:
    type: string
  investigator:
    type: string
  library_construction_protocol:
    type: string
  library_strategy:
    type: string
  organism:
    type: string
  pi_name:
    type: string
  processing_date:
    type: string
  samples:
    type:
      type: array
      items:
        type: record
        fields:
          library_nickname:
            type: string
          sample_id:
            type: string?
          fastq_dir:
            type: Directory
          expect_cells:
            type: int
          instrument_model:
            type: string
          read1_length:
            type: int
          read2_length:
            type: int
          library_prep:
            type: string
          characteristics:
            type:
              type: array
              items:
                type: record
                name: characteristics
                fields:
                  name:
                    type: string
                  value:
                    type: string
  sequencing_center:
    type: string
  sequencing_date:
    type: string
  transcriptome:
    type: Directory
  treatment_protocol_description:
    type: string

outputs:
  output_aggr_dir:
    type: Directory
    outputSource: step_cellranger_aggr/output_dir
  output_single_dir:
    type: Directory[]
    outputSource: step_cellranger_count/output

steps:

  step_parse_samples:
    run: parse_samples.cwl
    in:
      samples: samples
    out:
      - library_nicknames
      - sample_ids
      - fastq_dirs
      - expect_cells

  step_cellranger_count:
    run: cellranger_count.cwl
    scatter:
      - library_nickname
      - sample_id
      - fastqs
      - expect_cells
    scatterMethod: dotproduct
    in:
      library_nickname: step_parse_samples/library_nicknames
      sample_id: step_parse_samples/sample_ids
      fastqs: step_parse_samples/fastq_dirs
      transcriptome: transcriptome
      expect_cells: step_parse_samples/expect_cells
    out:
      - output

  step_cellranger_aggr:
    run: cellranger_aggr.cwl
    in:
      aggr_nickname: aggr_nickname
      normalize: aggr_norm_method
      h5_basedirs: step_cellranger_count/output
    out:
      - output_dir
      - aggregate_csv
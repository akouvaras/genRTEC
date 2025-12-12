# genRTEC: A prompting approach that leverages the power of LLMs for constructing executable MAS specifications.

# License

This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions; See the [GNU General Public License v3 for more details](https://www.gnu.org/licenses/gpl-3.0.en.html).

# Feedback 

For more information and feedback, do not hesitate sending us an email or adding an issue in this repository.

# Instructions for reproducing the experiments
## 1. Generating LLM Rules
To reproduce the experiments, use the prompt files contained in the 'prompts/' directory in the order they appear in the folder. These prompts can be used with any LLM (e.g., GPT, Gemini, Claude). 

## 2. To measure syntactic similarity:
1. Create a '.prolog' file containing the LLM-generated rules for each application.
2. Use the ground truth rules located in 'rules/ground_truth/syntactic_similarity/' as the comparison baseline.
3. Run the **[simLP](https://github.com/Periklismant/simLP)** tool to compute the syntactic similarity.

## 3. To measure f1-score (predictive accuracy):
1. Run RTEC on the ground truth rules located in 'rules/ground_truth/predictive_accuracy'.
2. Duplicate these files and replace the ground truth rules with the LLM-generated rules.
3. Execute the 'evaluate.py' located in the repository of **[RTEC](https://github.com/aartikis/RTEC/tree/master/execution%20scripts/scoring)**.

The 'rules/llms' directory contains the LLM-generated rules provided by each LLM for each experiment. 

### Directory Structure
```bash
.
├── prompts/                   
│   ├── 01_introducing_rtec.txt
│   ├── 02_net.txt
│   ├── 03_vp.txt
│   ├── 04_arg.txt
│   ├── 05_msa.txt
│   ├── 06_acr.txt
│   ├── 07_ctm.txt
│   └── 08_cg.txt
│
└── rules/                      
    └── ground_truth/                  
    └── llms/                   
        └── claude/
            └── exp1/       
                ├── predictive_accuracy/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/   
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
            └── exp2/           
                ├── predictive_accuracy/     
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/   
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
            └── exp3/          
                ├── predictive_accuracy/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/   
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
            └── exp4/           
                ├── predictive_accuracy/     
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
            └── exp5/           
                ├── predictive_accuracy/     
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
        └── gemini/
            └── exp1/           
                ├── predictive_accuracy/     
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
            └── exp2/           
                ├── predictive_accuracy/     
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
            └── exp3/           
                ├── predictive_accuracy/     
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
            └── exp4/           
                ├── predictive_accuracy/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
            └── exp5/           
                ├── predictive_accuracy/   
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
        └── gpt/
            └── exp1/           
                ├── predictive_accuracy/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/   
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
            └── exp2/           
                ├── predictive_accuracy/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
            └── exp3/           
                ├── predictive_accuracy/     
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
            └── exp4/           
                ├── predictive_accuracy/     
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
            └── exp5/           
                ├── predictive_accuracy/    
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog
                └── syntactic_similarity/   
                    ├── acr.prolog
                    ├── ctm.prolog
                    ├── msa.prolog
                    ├── net.prolog
                    └── vp.prolog

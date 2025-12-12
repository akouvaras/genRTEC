# genRTEC: A prompting approach that leverages the power of LLMs for constructing executable MAS specifications.

# License

This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions; See the [GNU General Public License v3 for more details](https://www.gnu.org/licenses/gpl-3.0.en.html).

# Feedback 

For more information and feedback, do not hesitate adding an issue in this repository.

# Instructions for reproducing the experiments



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

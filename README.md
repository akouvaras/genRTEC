# genRTEC: A prompting approach that leverages the power of LLMs for constructing executable MAS specifications.

# Directory Structure:
├── prompts/                    # Prompts for each application
│   ├── 01_introducing_rtec.txt
│   ├── 02_net.txt
│   ├── 03_vp.txt
│   ├── 04_arg.txt
│   ├── 05_msa.txt
│   ├── 06_ar.txt
│   ├── 07_ctm.txt
│   └── 08_cg.txt
│
└── rules/                      # Includes hand-crafted (folder: rtec) and LLM-generated rules (folder: llms). 
    └── llms/                   # Includes rule-sets for claude, gemini, gpt, qwen. 
        └── claude/
            └── exp1/           # For each experiment there are two folders i.e., predictive_accuracy, syntactic_similarity. 
                ├── predictive_accuracy/     # Rules that one need in order to reasoning and compute predictive accuracy using [RTEC](https://github.com/aartikis/rtec). 
                └── syntactic_similarity/    # Rules that one need in order to compute syntactic similarity using [simLP](https://github.com/Periklismant/simLP). 


# License

This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions; See the [GNU General Public License v3 for more details](https://www.gnu.org/licenses/gpl-3.0.en.html).

# Feedback 

For more information and feedback, do not hesitate adding an issue in this repository.


# Related Software
- [RTEC](https://github.com/aartikis/rtec): Run-Time Event Calculus. RTEC is an Event Calculus implementation optimised for stream reasoning. 
- [iRTEC](https://github.com/eftsilio/Incremental_RTEC): Incremental RTEC. iRTEC supports incremental reasoning, handling efficiently the delays and retractions in data streams.
- [oPIEC](https://github.com/Periklismant/oPIEC): Online Probabilistic Interval-Based Event Calculus. oPIEC supports Event Calculus reasoning over data streams under uncertainty.
- [Wayeb](https://github.com/ElAlev/Wayeb): Wayeb is a Complex Event Processing and Forecasting (CEP/F) engine written in Scala. It is based on symbolic automata and Markov models.
- [simLP](https://github.com/Periklismant/simLP): simLP. A Similarity Metric for Logic Programs. 

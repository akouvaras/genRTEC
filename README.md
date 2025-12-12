# genRTEC: A prompting approach that leverages the power of LLMs for constructing executable MAS specifications.

# License

This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions; See the [GNU General Public License v3 for more details](https://www.gnu.org/licenses/gpl-3.0.en.html).

# Feedback 

For more information and feedback, do not hesitate adding an issue in this repository.

# Instructions for reproducing the experiments



### Directory Structure
```bash
.
├── prompts/                    # Prompts for each application
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
    └── ground_truth/                   # Includes ground-truth rules
    └── llms/                   # Includes rule sets for Claude, Gemini, GPT
        └── claude/
            └── exp1/           # Experiment 1
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.
            └── exp2/           # Experiment 2
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.
            └── exp3/           # Experiment 3
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.
            └── exp4/           # Experiment 4
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.
            └── exp5/           # Experiment 5
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.
        └── gemini/
            └── exp1/           # Experiment 1
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.
            └── exp2/           # Experiment 2
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.
            └── exp3/           # Experiment 3
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.
            └── exp4/           # Experiment 4
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.
            └── exp5/           # Experiment 5
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.
        └── gpt/
            └── exp1/           # Experiment 1
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.
            └── exp2/           # Experiment 2
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.
            └── exp3/           # Experiment 3
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.
            └── exp4/           # Experiment 4
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.
            └── exp5/           # Experiment 5
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.

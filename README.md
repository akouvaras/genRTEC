# genRTEC: A prompting approach that leverages the power of LLMs for constructing executable MAS specifications.

# License

This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions; See the [GNU General Public License v3 for more details](https://www.gnu.org/licenses/gpl-3.0.en.html).

# Feedback 

For more information and feedback, do not hesitate adding an issue in this repository.

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
└── rules/                      # Includes hand-crafted (folder: rtec) and LLM-generated rule sets (folder: llms)
    └── llms/                   # Includes rule sets for Claude, Gemini, GPT, and Qwen
        └── claude/
            └── exp1/           # Each experiment contains two folders: predictive_accuracy and syntactic_similarity
                ├── predictive_accuracy/     # Rules needed for reasoning and computing predictive accuracy using RTEC.
                └── syntactic_similarity/    # Rules needed for computing syntactic similarity using simLP.

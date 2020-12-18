UNI: xl2891
Name: Xudong Liang (Brandon)
Date: 12/17/2020

---------------------

Note: my main executable scripts (./bin/train.sh & ./bin/test.sh) do not follow the Kaldi Ted-Lium run.sh script, even though the underlying workflow closely follows that of the Ted-Lium recipe. Therefore, according to TA response in Piazza post @113_f1, I do not need to include the .diff file in my main directory.

---------------------

Project Title: Including Punctuation, Capitalization and Numeral in Automatic Speech Recognition

Project Summary
In traditional Automatic Speech Recognition (ASR) systems, the generated transcript output is typically unsegmented text that includes only the plain word tokens and excludes other sentence components, such as punctuations, capitalized phrases and numerals, due to text normalization in preprocessing. Although such transcripts containing word tokens alone can provide sufficient translation of the speech audio, the other sentence components are also crucial to understanding the message. In this work, I propose modification in the lexicon, acoustic model, and language model components to a tpyical ASR architecture to include punctuation, capitalization and numeral in the predicted transcript. 

I take the TedLium lexicon as the default lexicon. First, for Capitalization, I simply duplicate the original word-to-pronunciation mappings and capitalize the 1st letter of each word. Then, for numeral, there are two categories: For Rule-based category, I get the pronunciations of the basic number units and for the majority of other numbers, I piece together their pronunciations following the rules of how we normally pronounce a number. For example, 111 is 1 plus hundred plus and plus 11. The other category, i simply spell out the pronunciation of each digit and piece them together. This would be how we pronounce ID's or long numbers. Lastly, for punctuation, I come up with 2 verions. Version 1 attaches each punctuation to the end of each word token, as normal text tokenization would attach punctuations to the end of preceding word tokens. This increases the lexicon size by a factor of unique punctuation count and is thus quite impractical. Version 2 treats punctuations as standalone tokens and I use NLTK WordPunctTokenizer to tokenize the original transcripts.

Thus, in total, there are two lexicon versions, hence two ASR model versions to train and evaluate.

For Acoustic and Language Modeling, I follow the TedLium recipe to get both statistical GMM-HMM 4-Gram model and neural TDNN RNNLM model.

Below is the test Word Error Rate (WER) result of the ASR model for both versions. Expectedly, Version 2 performs better than Version 1 for statistical model, although still worse than Ted-Lium result. Thus, I run Version 2 again through the neural Acoustic and Language models and get its WER in the right column.
# Complete when result are here

# Complete Table

-------------------------------------------------------------------
| ASR Model         | AM: GMM-HMM, LM: 4-Gram | AM: TDNN, LM: RNN |
-------------------------------------------------------------------
| Ted-Lium          |                         |                   |
|                   |           16.1%         |         6.7%      |
| (Traditional ASR) |                         |                   |
-------------------------------------------------------------------
| Version 1 -       |                         |                   |
| Punct Attached    |           39.7%         |         --        |
| (Enhanced ASR)    |                         |                   |
-------------------------------------------------------------------
| Version 2 -       |                         |                   |
| Punct Tokenized   |           32.5%         |                   |
| (Enhanced ASR)    |                         |                   |
-------------------------------------------------------------------

--------------------

List of Tools: Python Prerequisites

    I use a few python packages (e.g.: NLTK, Pandas, etc.) in preprocessing. The detailed python packages are listed in ./requirements.txt and can be installed using:
        pip install -r requirements.txt

    List of Tools: Kaldi Documentation & External Resource
        CMU Pronouncing Dictionary (http://www.speech.cs.cmu.edu/cgi-bin/cmudict) - for ARPAbet-transcribed pronunciations of the basic number units
        CMU LOGIOS Lexicon Tool (http://www.speech.cs.cmu.edu/tools/lextool.html) - for ARPAbet-transcribed pronunciations of all possible numbers under 10,000
        Kaldi Documentaion (http://kaldi-asr.org/doc) - for data preparation and variou Kaldi documentaions
        Kaldi Ted-Lium recipe and various executables in utils/, steps/ and local/

--------------------

List of Directories and Executables:

    ./requirements.txt - required python libraries
    ./python/
        append_lexicon.py - appends punctuation, capitalization and numeral to lexicon for Version 1
        append_lexicon_punct_tokenized.py - appends punctuation, capitalization and numeral to lexicon for Version 2
        data_prep.py - data preparation into Kaldi requirement
        keep_original_script.py - keeps only the original script of the transcript from Singapore National Speech Corpus
        number_generator.py - generates numbers below a certain threshold
        tokenized_text.py - tokenize text using NLTK PunctWordTokenizer for Version 2
        train_dev_test_split.py - split prepared Kaldi-format data (text, wav.scp, utt2spk, etc.) into train, dev and test set using 8:1:1 ratio
    ./conf/
        env.sh - stores environment variables for all bash shell executable scripts (i.e.: VERSION to control which version to run)
    ./bin/ - bash shell scripts/executables
        (code by Kaldi)
            conf/ - Kaldi Ted-Lium conf/
            local/ - Kaldi Ted-Lium local/
            steps/ - Kaldi Ted-Lium steps/
            utils/ - Kaldi Ted-Lium utils/
            rnnlm/ - Kaldi Ted-Lium rnnlm/
            cmd.sh - follows Kaldi recipe, decides whether to run locally or queue on cluster
            path.sh - follows Kaldi recipe, specifices local path dependencies
        (code by me)
            old/ - scripts to be discarded
            append_lexicon_v1.sh - appends Version 1 lexicon to default Ted-Lium lexicon
            append_lexicon_v2.sh - appends Version 2 lexicon to default Ted-Lium lexicon
            cp_dict_to_data_v1.sh - copies generated Kaldi dictionary files into pre-defined Kaldi local/dict directory for Version 1
            cp_dict_to_data_v2.sh - copies generated Kaldi dictionary files into pre-defined Kaldi local/dict directory for Version 2
            create_lang_dir_L_fst.sh - creates the lang directory using Kaldi script which creates L.fst & L_disambig.fst
            data_prep_v1.sh - prepares data into required Kaldi format (text, wav.scp, utt2spk, etc.) for Version 1
            data_prep_v2.sh - prepares data into required Kaldi format (text, wav.scp, utt2spk, etc.) for Version 2
            decode_sat_triphone.sh - decodes Speaker Adapted Training (SAT) Triphone GMM-HMM model to get prediction and WER
            keep_original_script.sh - keeps only the original script in NSC transcript in data preparation stage
            monophone_training_alignment.sh - Monophone training and alignment
            number_generator_v1.sh - number generator for numeral lexicon for Version 1
            number_generator_v2.sh - number generator for numeral lexicon for Version 2
            rescore_lattices.sh - resores the lattices after RNNLM using pruned LM rescoring
            results.sh - gets WER from decoding
            run_rnnlm.sh - runs RNNLM after TDNN
            run_tdnn.sh - runs TDNN after Triphone training
            test.sh - main test script (see below)
            train.sh - main train script (see below)
            train_dev_test_split_v1.sh - splits prepared Kaldi-format data into train, dev & test sets using 8:1:1 ratio for Version 1
            train_dev_test_split_v2.sh - splits prepared Kaldi-format data into train, dev & test sets using 8:1:1 ratio for Version 2
            train_lm_arpa_G_fst.sh - trains an N-Gram ($LM_ORDER) language model and generates lm.arpa & G.fst ($LM_ORDER defined in ./conf/env.sh)
            triphone_training_alignment.sh - Triphone training and alignment (including delta-based, delta + delta, LDA-MLLT & SAT)
    ./tedlium_dict_data/local/dict/ - dictionary files from Ted-Lium recipe (used as default dictionary files)
        lexicon.txt
        nonsilence_phones.txt
        optional_silence.txt
        silence_phones.txt
    ./nsc_dict_data/local/ (I do not include lexicon.txt since it can be quite big)
        dict/ - dictionary files for Version 1 of this project (NSC data)
            nonsilence_phones.txt
            numbers.txt
            numeral_lexicon_base.bsv
            numeral_lexicon_dumb.tsv
            optional_silence.txt
            silence_phones.txt
        dict_v2/ - dictionary files for Version 2 of this project (NSC data)
            nonsilence_phones.txt
            numbers.txt
            numeral_lexicon_base.bsv
            numeral_lexicon_dumb.tsv
            optional_silence.txt
            silence_phones.txt
    ./data/ - sample data directory for demonstration purpose
        ./train - directory for sample training data in Kaldi format
            reco2dur
            conf/
            data/ - intermediate scp & ark files (I emptied the ark files)
            frame_shift
            text
            wav.scp
            feats.scp
            cmvn.scp
            utt2spk
            spk2utt
            utt2dur
            utt2num_frames
        ./lang_v2 - directory for language dictionary files for Version 2 (Version 1 Lexicon is very large, there discarded here)
    ./exp_v1/ - directory for Version 1 Kaldi model artifacts
        tri4a_ali/ - GMM-HMM Model (Monophone + Triphone) Decoding & Scoring Results on dev & test
            decode_dev/
            decode_dev.si/
            decode_dev_rescore/
            decode_test/
            decode_test.si/
            decode_test_rescore/
    ./exp_v2/ - directory for Version 2 Kaldi model artifacts
        tri4a_ali/ - GMM-HMM Model (Monophone + Triphone) Decoding & Scoring Results on dev & test
            decode_dev/
            decode_dev.si/
            decode_dev_rescore/
            decode_test/
            decode_test.si/
            decode_test_rescore/
        # to be completed - TDNN + RNNLM Model Decoding & Scoring Restuls on dev & test
    ./prediction_v?/ - directory for decoded prediction (in word tokens) for Version 1 & 2
        ${MODEL}/decode_test_rescore/decoded_text.txt - decoded text using lattice-best-path as model prediction (generated by Test script below)

--------------------

Train Script

    ./bin/train.sh - to be run inside ./bin/
        To run:
            - cd into ./bin (this is IMPORTANT)
            - ./train.sh
            - The arguments are already configured and stored in each sub-executables in ./bin/ (see above) and ./conf/env.sh so there is no need to pass arguments to this script. To change arguments, please refer to ./conf/env.sh and the used sub-executables in ./bin/.

    To change model version, see $VERSION in ./conf/env.sh.

    This script runs the training process of my ASR model from scratch:
        Stage 1 - Data Prep (following http://kaldi-asr.org/doc/data_prep.html)
            prepares the NSC dataset into Kaldi-required format (text, wav.scp, utt2spk, etc.), splits them into train, dev & test set using 8:1:1 ratio, creates spk2utt, extracts MFCC features and does CMVN.
        Stage 2 - dictionary, lang and LM
            appends the lexicon pronunciation mapping of punctuation (2 versions), capitalization & numeral to the default Ted-Lium lexicon, copies the generated dictionary files into pre-defined Kaldi local/dict directory, creates the lang directory using Kaldi scripts and trains the N-Gram language model
        Stage 3 - Statistical Modeling
            runs through monophone and triphone (delta-based, delta + delta, LDA-MLLT & SAT) training and alignment to get the GMM-HMM model and decodes the model to get prediction and WER
        Stage 4 - Neural Modeling
            runs through TDNN and RNNLM to get the final model and decodes the model to get prediction and WER

    Note that it will most likely crash because the actual Kaldi-required data/ and exp/ directories are not stored in this repository.

    Sample Decoding Files:
        decoded lattices: ./exp_v?/tri4a_ali/decode_*/lat.*.gz
        decoded text (prediction, in token ids): ./exp_v?/tri4a_ali/decode_*/trans.*
        WER of decoded text compared to ground truth: ./exp_v?/tri4a_ali/decode_*/wer_*

--------------------

Test Script

    ./bin/test.sh - to be run inside ./bin/
        To run:
            - cd into ./bin (this is IMPORTANT)
            - ./test.sh
            - The arguments are already configured and stored in this script and ./conf/env.sh so there is no need to pass arguments to this script. To change arguments, please refer to ./conf/env.sh and ./bin/test.sh.

    This script essentially finds best lattice path and converts the token ids from the decoded text to actual word tokens using word.txt in language directory, to make the decoding result human-readable.

    The current configuration decodes the test lattice of GMM-HMM model for Version 2. To change model, see $MODEL_DIR in ./bin/test.sh. To change model version, see $VERSION in ./conf/env.sh.

    The prediction result can be found under ./prediction_${VERSION}/${MODEL}/decode_test_rescore/decoded_text.txt

--------------------

Sample Data, Dict and Lang Directory

    see ./data/, ./nsc_dict_data/local/{dict, dict_v2}/, ./lang_v2/ from List of Directories above

    Note: I do not include the raw data of Singapore NSC here since it is not considered a new/custom dataset.

    Note: these are not the actual data locations I use in Kaldi training (please see $KALDI_DATA_LOCATION in ./conf/env.sh)

--------------------

Sample Model Artifact Directory

    see ./exp_v?/ from List of Directories above

    Note: these are not the actual model/artifact locations I use in Kaldi training (please see $KALDI_MODEL_LOCATION in ./conf/env.sh)

--------------------

Sample Prediction Directory

    see ./prediction_v?/ from List of Directories and Test Script above

--------------------

This fork of PyLaia is used as 3rd step in a pipelining project in context of course Foundation of Digital Humanities (DH-405) given in fall 2020 at EPFL.
Refer to the main [repository](https://github.com/Jmion/VeniceTimeMachineSommarioniHTR) of the project to access to the whole pipeline.
The full documentation and explanation of the project can be found on the [project wiki page](http://fdh.epfl.ch/index.php/Deciphering_Venetian_handwriting).
To know how to run this step, refer to section FDH Project - Decipher venice below. To install and setup PyLaia refer to the standard starting in PyLaia i.e:[IAM example for HTR](egs/iam-htr).

# PyLaia

[![Build Status](https://travis-ci.com/jpuigcerver/PyLaia.svg?token=HF64eTvPxEUcjjUPXpgm&branch=master)](https://travis-ci.com/jpuigcerver/PyLaia)
[![Python Version](https://img.shields.io/badge/python-3.5%2C%203.6%2C%203.7-blue.svg)](https://www.python.org/)
[![Code Style](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/ambv/black)

PyLaia is a device agnostic, PyTorch based, deep learning toolkit specialized
for handwritten document analysis. It is also a successor to
[Laia](https://github.com/jpuigcerver/Laia).

> **Disclaimer**: The easiest way to learn to use PyLaia is to follow the
> [IAM example for HTR](egs/iam-htr). Apologies for not having a better
> documentation at this moment, I will keep improving it and adding other
> examples.

## Installation

In order to install PyLaia, follow this recipe:

```bash
git clone https://github.com/jpuigcerver/PyLaia
cd PyLaia
pip install -r requirements.txt
python setup.py install
```

The following Python scripts will be installed in your system:

- **pylaia-htr-create-model**: Create a VGG-like model with BLSTMs on top for
  handwriting text recognition. The script has different options to costumize
  the model. The architecture is based on the paper ["Are Multidimensional
  Recurrent Layers Really Necessary for Handwritten Text Recognition?"](https://ieeexplore.ieee.org/document/8269951)
  (2017) by J. Puigcerver.
- **pylaia-htr-decode-ctc**: Decode text line images using a trained model and
  the CTC algorithm.
- **pylaia-htr-train-ctc**: Train a model using the CTC algorithm and a set of
  text-line images and their transcripts.
- **pylaia-htr-netout**: Dump the output of the model for a set of text-line images
  in order to decode using an external language model.

Some examples need additional tools and packages, which are not installed
with `pip install -r requirements.txt`.
For instance, typically ImageMagick is used to process images, or Kaldi
is employed to perform Viterbi decoding (and lattice generation) combining
the output of the neural network with a n-gram language model.

# Modifications

- Added args `pretrained_checkpoint` in `pylaia-htr-train-ctc` to use a pretrained checkpoint.
- Created a new experiment for iam-htr with batch norm and distortion (data augmentation), gain of 2-3% CER.
- Create a new dataset, `lausanne-census`, for Lausanne census data with relevant data preparation scripts and experiments.

# FDH Project - Decipher venice

## Train on IAM

### Datatset description

Images :
- lines
- sentences
- words

Text :
- forms.txt : global index of the dataset
- lines.txt : descriptions and transcriptions of lines images
- sentences.txt : descriptions and transcriptions of sentences images
- words.txt : descriptions and transcriptions of words images
    

### Training pipeline

Using the code that is in egs/iam-htr.

1. Install PyLaia as above 
2. Install dependencies (see [IAM example for HTR](egs/iam-htr))
    - [ImageMagick](https://www.imagemagick.org/):
  Needed for processing the images.
    - [imgtxtenh](https://github.com/mauvilsa/imgtxtenh):
  Needed for processing the images.
    - gawk
2. Put iam dataset in egs/iam-htr/data/original
3. Put iam splits in egs/iam-htr/splits
    - Downloaded from [here](https://www.prhlt.upv.es/~jpuigcerver/iam_splits.tar.gz)
    - It contains several splits of the dataset (training set, validation set, test set) already used in several papers 
4. Run egs/iam-htr/src/prepare_images.sh
    - It takes the images from the folder original (lines and sentences). It put prepared images in imgs
    - Step 1 : cleaning, enhancing of the images (output : data/imgs/lines or data/imgs/sentences/)
    - Step 2 : resizing of the images (output : data/imgs/lines_h128 or data/imgs/sentences_h128/)
5. Run egs/iam-htr/src/prepare_texts.sh  
    - It takes text from original. It put prepared text in lang. It needs the splits folder
    - Text preparation includes : removing spaces in words, replacing | by space ,.. 
    - It directly puts the text in the different splits folder for both words and character levels
6. Run egs/iam-htr/src/train_puigcerver17_bn_dist.sh (train the model) (training on GeForce GTX TITAN X with 12 GB)
    - create egs/iam-htr/exper/puigcerver17_bn_dist
    - Store num_rolling_checkpoins relevant checkpoints (when new lowest CER and WER are reached, and each 10 epochs)
    - Store logs model
    - Store the symbol table in syms_ctc.txt 
7. Run egs/iam-htr/src/decode_net
    - Evaluate the model on validation and training set
    - Store results in egs/iam-htr/decode
    - It does not compute CER/WER if kaldi is not installed
8. We can evaluate the model with egs/iam-htr/src/Evalutation.ipynb
    - experiment.ckpt.lowest-valid-cer-54 CER : 0.0716 WER : 0.228


## Transfer learning on VTM dataset

Based on the code that was in egs/lausanne-census, but work on folder egs/decipher-venice

### Datatset description 
The VTM dataset consists of images paired with a transcription.

Images are JPEG files and transcription are TXT files. Each files of the pair has the same id as filename.

### Pipeline

#### Training

1. Copy the vtm dataset in egs/decipher-venice/data/original
2. Prepare images : run egs/decipher-venice/src/prepare_images.sh
    - if imgtxtenh is missing : export PATH=/usr/local/bin:$PATH
    - do the same thing as /iam-htr/src/prepare_images.sh
    - output in egs/decipher-venice/data/imgs/lines and egs/decipher-venice/data/imgs/lines_h128 
3. Split : run egs/decipher-venice/src/split_data.sh
    - output : egs/decipher-venice/data/splits
    - 3 files : te.lst, tr.lst, va.lst
4. Prepare texts : run egs/decipher-venice/src/prepare_texts.sh
    - output : lang/all/char.txt
    - Potential problems : encoding
5. Transform texts run egs/decipher-venice/src/prepare_text_stage2.py
    - remove .txt in ids
6. In egs/decipher-venice/src/train_puigcerver17_transfer_bn_dist.sh point to the right checkpoint to begin the training. The variable to update is the pretrained_checkpoint.
7. Train : run egs/decipher-venice/src/train_puigcerver17_transfer_bn_dist.sh
    - specify the GPU !!!
8. Evaluate with egs/decipher-venice/src/Evalutation.ipynb
    - experiment.ckpt.lowest-valid-cer-31 CER : 0.05097 WER : 0.192
    
#### Decipher sommarioni
1. Segment patch in the images (see step 1 and 2 of the [project pipeline](https://github.com/Jmion/VeniceTimeMachineSommarioniHTR#-step-1%EF%B8%8F%E2%83%A3-baseline-detection))
2. Copy patch in egs/decipher-venice/data/sommarioni/reg# OR put the rights paths in egs/decipher-venice/src/prepare_sommarioni.sh
3. Run egs/decipher-venice/src/prepare_sommarioni.sh
4. See the results in egs/decipher-venice/src/Decipher_sommarioni.ipynb


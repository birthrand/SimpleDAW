# SimpleDAW
SimpleDAW is an audio recorder with pitch shifting and pitch detection for iOS


## Table of Contents

- [Introduction](#introduction)
- [Screenshots](#screenshots)
- [Features](#features)
- [Feedback](#feedback)
- [Author](#author)

## Introduction

SimpleDAW allows you to create audio recordings of yourself, shift the pitch of audio recordings to create fun sounding effects. You can also sing into the microphone and see what frequency and pitch you're singing on.


## Screenshots

**Developed for iOS devices running version 13.2 and above**

The SimpleDAW user interface has three screens. This is the main screen.


<p align="center">
  <img src = "/images/main.PNG" width=300>
</p>


Tapping the Audio Recorder button  on the main screen will navigate you to the Audio Recorder screen. 

The screen features two tabs, the audio recording tab and the audio playback and pitch shifting tab.

You start and stop a new recording by tapping the microphone button.

<p align="center">
  <img src = "/img/audioStart.PNG" width=300>
  <img src = "/img/audioStop.PNG" width=300>
</p>


Select a saved audio from the list and press the Play/Pause/Stop buttons for playback controls.


<p align="center">
  <img src = "/img/audioPause.PNG" width=300>
  <img src = "/img/audioPlay.PNG" width=300>
</p>


Swipe left and tap 'Delete' on a selected recording to delete a saved recording.
 You can record and save multiple recordings.
 
 
<p align="center">
  <img src = "/img/audioMulti.PNG" width=350>
  <img src = "/img/audioDelete.PNG" width=350>
</p>


Tapping the Pitch Detector button on the main screen  will navigate you to the Pitch Detection screen. 
To beging pitch detection, tap the Detect Pitch button and sing into the microphone.


<p align="center">
  <img src = "/img/detectDefault.PNG" width=300>

  <img src = "/img/detectOne.PNG" width=300>

  <img src = "/img/detectTwo.PNG" width=300>
</p>

## Components
SimpleDAW uses the [AudioKit](https://github.com/AudioKit/AudioKit) library to get a music pitch with its note and amplitude from a specified frequency.

## Features

A few of the things you can do with the SimpleDAW application:

* Add and delete recordings
* Play/Pause/Stop a saved audio recording
* Shift the pitch of a selected audio recording 
* Detect and display the frequency and pitch from the user's microphone 

## Feedback
If there's anything you'd like to chat about, please feel free email the author at bcn991@uregina.ca

## Author

This project was developed by Betrand Nnamdi for the 2020 CS827 Computer Audio Final Project

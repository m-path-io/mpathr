% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{example_data}
\alias{example_data}
\title{Example m-path data}
\format{
A data frame with 1980 rows and 47 columns:
\describe{
\item{participant}{Participant identifier.}
\item{code}{Code the participants used to sign up for the study.}
\item{questionnaire}{The questionnaire that participants answered
in that beep (it can be the main or the evening questionnaire).}
\item{scheduled}{Time stamp for when the notification was scheduled for,
in unix time.}
\item{sent}{Time stamp for when the notification was sent, in unix time.}
\item{start}{Time stamp for when the notification was answered,
in unix time.
If the notification was never answered, this value is an NA.}
\item{stop}{Time stamp for when the notification was completed,
in unix time.
If the notification was never answered, this value is an NA.}
\item{phone_server_offset}{The difference between the phone time
and the server time.}
\item{obs_n}{Observation number for each participant.
Goes from 1 (first observation), to 110 (last observation of the study).}
\item{day_n}{Day number of the study, for the participant.
Goes from 1 to 10.}
\item{obs_n_day}{Observation number within the day (for each participant).
Goes from 1 to 11.}
\item{answered}{Logical, whether the beep was answered or not.}
\item{bpm_day}{Average heart rate per day.
Note that unlike the rest of the variables,
this corresponds to simulated data.}
\item{gender}{Participant's gender.
1 means 'Male', 2 means 'Female', 3 'Other'.}
\item{gender_string}{Participant's gender, as a string.}
\item{age}{Participant's age in years.}
\item{life_satisfaction}{Composite variable corresponding to participant's
life satisfaction according to the Satisfaction With Life Scale (SWLS).}
\item{neuroticism}{Composite variable corresponding to participant's
neuroticism according to the Big Five Inventory (BFI).}
\item{slider_happy}{Participants' self-reported happiness
at the time of the beep.
From 0 (not happy at all) to 100 (very happy).}
\item{slider_sad}{Participants' self-reported sadness
at the time of the beep.
From 0 (not sad at all) to 100 (very sad).}
\item{slider_angry}{Participants' self-reported anger
at the time of the beep.
From 0 (not angry at all) to 100 (very angry).}
\item{slider_relaxed}{Participants' self-reported relaxation
at the time of the beep.
From 0 (not relaxed at all) to 100 (very relaxed).}
\item{slider_anxious}{Participants' self-reported anxiety
at the time of the beep.
From 0 (not anxious at all) to 100 (very anxious).}
\item{slider_energetic}{Participants' self-reported energy
at the time of the beep.
From 0 (not energetic at all) to 100 (very energetic).}
\item{slider_tired}{Participants' self-reported tiredness
at the time of the beep.
From 0 (not tired at all) to 100 (very tired).}
\item{location_index}{Index corresponding to the participant's answer
to the question "Where are you now?",
from a list of multiple options.}
\item{location_string}{Text corresponding to the participant's selected
location at the time of the beep.}
\item{company_index}{Index corresponding to the participant's answer to the
question "With whom are you right now?", from a list of multiple options.}
\item{company_string}{Text corresponding to the participant's selected
company at the time of the beep.}
\item{activity_index}{Index corresponding to the participant's answer to
the question "What are you doing now?", from a list of multiple options.}
\item{activity_string}{Text corresponding to the participant's selected
activity at the time of the beep.}
\item{step_count}{Step count between the previous answered beep and the
current beep}
\item{evening_slider_happy}{Participants' happiness during the day,
from 0 (not happy at all) to 100 (very happy).}
\item{evening_slider_sad}{Participants' sadness during the day,
from 0 (not sad at all) to 100 (very sad).}
\item{evening_slider_angry}{Participants' anger during the day,
from 0 (not angry at all) to 100 (very angry).}
\item{evening_slider_relaxed}{Participants' relaxation during the day,
from 0 (not relaxed at all) to 100 (very relaxed).}
\item{evening_slider_anxious}{Participants' anxiety during the day,
from 0 (not anxious at all) to 100 (very anxious).}
\item{evening_slider_energetic}{Participants' energy during the day,
from 0 (not energetic at all) to 100 (very energetic).}
\item{evening_slider_tired}{Participants' tiredness during the day,
from 0 (not tired at all) to 100 (very tired).}
\item{evening_stressful}{Participant's answer to whether something
stressful had happened during the day. 1 means 'yes', 0 means 'no'.}
\item{evening_positive}{Participant's answer to whether something
positive had happened during the day. 1 means 'yes', 0 means 'no'.}
\item{positive_description}{Explanation of the positive event
(if participants responded 'yes' to the previous question).}
\item{stressful_description}{Explanation of the stressful event
(if participants responded 'yes' to the previous question).}
\item{evening_activity_index}{Index corresponding to the participant's
answer(s) to the question "What activities did you do today?",
from a list of multiple options.}
\item{evening_activity_string}{Text corresponding to the participant's
selected activities during the day.}
\item{delay_start_min}{Delay in minutes between the scheduled beep and the
time the participants started the beep.}
\item{delay_end_min}{Time in minutes the participants took to fill in
the beep (difference between the columns start and stop).}
}
}
\usage{
example_data
}
\description{
Contains the preprocessed example data for an m-path research study.

In the study, 20 participants completed 11 beeps over the course of 10 days.
The study consisted of:
\itemize{
\item An intake questionnaire, that participants answered at the study's start.
\item A main questionnaire (10 times per day), where participants answered
questions about their emotions and context at the time.
\item An evening questionnaire (once, at the end of the day),
about their emotions and activities throughout the day.
}

Each row corresponds to one beep sent during the study.
}
\keyword{datasets}

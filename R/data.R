#' Example m-path data after pre-processing
#'
#' Contains the pre-processed example data for an m-path research study.
#'
#' Each row corresponds to one beep sent during the study.
#'
#' @format
#' A data frame with 1980 rows and 47 columns:
#' \describe{
#'   \item{participant, code}{Participant identifier variables}
#'   \item{questionnaire}{the questionnaire that participants answered in that beep (it can be the main or the evening questionnaire)}
#'   \item{scheduled, sent, start, stop, phone_server_offset}{Variables corresponding to the timing of the beeps.}
#'   \item{phone_server_offset}{The difference between the phone time and the server time.}
#'   \item{obs_n, day_n, obs_n_day}{Variables corresponding to the observation number, day number, and observation number within the day, respectively.}
#'   \item{answered}{Logical, whether the beep was answered or not.}
#'   \item{...}{Other variables}
#' }
"example_data_preprocessed"

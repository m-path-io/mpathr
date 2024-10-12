#' Calculate response rate
#'
#' @param data data frame with data
#' @param valid_col name of the column that stores whether the beep
#' was answered or not
#' @param participant_col name of the column that stores the participant id
#' (or equivalent)
#' @param time_col optional: name of the column that stores the time of the
#' beep, as a 'POSIXct' object.
#' @param period_start string representing the starting date to
#' calculate response rates (optional). Accepts dates in the following
#' formats: \code{yyyy-mm-dd} or\code{yyyy/mm/dd}.
#' @param period_end period end to calculate response rates (optional).
#'
#' @returns a data frame with the response rate for each participant, and the number of beeps used to
#'   calculate the response rate
#' @export
#'
#' @examples
#' # Example 1: calculate response rates for the whole study
#' # Get example data
#' data(example_data)
#'
#' # Calculate response rate for each participant
#'
#' # We don't specify time_col, period_start or period_end.
#' # Response rates will be based on all the participant's data
#' response_rate <- response_rate(data = example_data,
#'                                valid_col = answered,
#'                                participant_col = participant)
#'
#' # Example 2: calculate response rates for a specific time period
#' data(example_data)
#'
#' # Calculate response rate for each participant between dates
#' response_rate <- response_rate(data = example_data,
#'                                valid_col = answered,
#'                                participant_col = participant,
#'                                time_col = sent,
#'                                period_start = '2024-05-15',
#'                                period_end = '2024-05-31')
#'
#' # Get participants with a response rate below 0.5
#' response_rate[response_rate$response_rate < 0.5,]
#'

response_rate <- function(
    data,
    valid_col,
    participant_col,
    time_col = NULL,
    period_start = NULL,
    period_end = NULL
){

  valid_col <- enquo(valid_col)
  participant_col <- enquo(participant_col)

  if(!missing(time_col)){
    time_col <- enquo(time_col)
   }

  # If period_start or end are specified, time_col should also be specified
  if(!is.null(period_start) | !is.null(period_end)){
    if(missing(time_col)){
      stop(paste(
        "It seems like the period start or end are specified",
        "but the time column is not. Please specify a time colum."
      ))
    }
  }

  # filter if a period start was specified
  if(!is.null(period_start)){
    data <- data |>
      filter(as.Date(!!time_col) >= as.Date(period_start))
  }

  # filter if a period end was specified
  if(!is.null(period_end)){
    data <- data |>
      filter(as.Date(!!time_col) <= as.Date(period_end))
  }

  # Print information on the period of the response rates.
  if (!is.null(period_start) & !is.null(period_end)) {
    message(paste("Calculating response rates between date:",
                  period_start, "and", period_end))
  } else if (!is.null(period_start)) {
    message(paste("Calculating response rates starting from date:",
                  period_start))
  } else if (!is.null(period_end)) {
    message(paste("Calculating response rates up to date:",
                  period_end))
  } else {
    message("Calculating response rates for the entire duration of the study.")
  }

  # grouping by the variable 'participant_col' and calculating number of beeps and response rate
  response_rate <- data |>
    group_by(!!participant_col) |>
    summarize(
      number_of_beeps = n(),
      response_rate = sum(!!valid_col) / n()
    )

  response_rate
}

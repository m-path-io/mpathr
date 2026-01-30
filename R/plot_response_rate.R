# this function is used by the function plot_response_rate (below).
response_rate_per_day <- function(
  data,
  valid_col,
  participant_col,
  time_col
) {
  # Get the timezone of the participant to use with as.Date()
  tz <- attr(pull(data, {{ time_col }}), "tzone")[[1]]
  tz <- if (is.null(tz)) "" else tz

  data <- data |>
    group_by({{ participant_col }}) |>
    mutate(day = as.POSIXlt({{ time_col }}, tz = tz)$mday) |>
    mutate(day = dplyr::dense_rank(.data$day)) |>
    ungroup() |>
    group_by({{ participant_col }}, .data$day) |>
    summarize(response_rate = sum({{ valid_col }}) / n(), .groups = "drop") |>
    ungroup()

  data
}

#' Plots response rate per day (and per participant)
#'
#' @description This function returns a ggplot object with the response rate per day (x axis) and
#' participant (color). Note that instead of using calendar dates, the function returns a plot
#' grouped by the day inside the study for the participant.
#'
#' @param data data frame with data
#' @param valid_col name of the column that stores whether the beep
#' was answered or not
#' @param participant_col name of the column that stores the participant id
#' (or equivalent)
#' @param time_col name of the column that stores the time of the beep
#'
#' @return a ggplot object with the response rate per day (x axis)
#' and participant (color)
#' @export
#'
#' @examples
#' # load data
#' data(example_data)
#'
#' # make plot with plot_response_rate
#' plot_response_rate(data = example_data,
#' time_col = sent,
#' participant_col = participant,
#' valid_col = answered)
#' # The resulting ggplot object can be formatted using ggplot2 functions (see ggplot2
#' # documentation).
#'
plot_response_rate <- function(
  data,
  valid_col,
  participant_col, # specify participant variable
  time_col # specify time variable
) {
  data_plot <- response_rate_per_day(
    data = data,
    valid_col = {{ valid_col }},
    participant_col = {{ participant_col }},
    time_col = {{ time_col }}
  )

  # turn participant into a factor for plotting purposes
  data_plot <- data_plot |>
    mutate(participant = as.factor({{ participant_col }}))

  # get n of participants for plotting purposes
  num_unique <- data_plot |>
    ungroup() |>
    summarise(unique = dplyr::n_distinct({{ participant_col }})) |>
    pull("unique")

  data_plot |>
    ggplot(
      aes(
        x = .data$day,
        y = .data$response_rate,
        group = .data$participant,
        color = .data$participant,
        shape = .data$participant,
        linetype = .data$participant
      )
    ) +
    ggplot2::geom_line() +
    ggplot2::geom_point() +
    ggplot2::scale_linetype_manual(
      values = rep(
        c("solid", "dashed", "dotted"),
        length.out = num_unique
      )
    ) +
    ggplot2::scale_shape_manual(
      values = rep(c(3, 8, 15, 16, 17, 18), length.out = num_unique)
    ) +
    ggplot2::labs(
      title = "Response rate per day",
      x = "Date",
      y = "Response rate"
    )
}

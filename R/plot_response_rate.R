#' Plots response rate per day (and per participant)
#'
#' @description
#' This function returns a ggplot object with the response rate per day (x axis)
#' and participant (color).
#' Note that instead of using calendar dates, the function returns a plot
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
#' # The resulting ggplot object can be formatted using ggplot2 functions
#' # (see ggplot2 documentation).
#'
plot_response_rate <- function(data,
                                valid_col,
                                participant_col,  # specify participant variable
                                time_col # specify time variable
){
  time_col <- enquo(time_col)
  participant_col <- enquo(participant_col)
  valid_col <- enquo(valid_col)

  data_plot <- response_rate_per_day(
    data = data,
    valid_col = !!valid_col,
    participant_col = !!participant_col,
    time_col = !!time_col
  )

  # turn participant into a factor for plotting purposes
  data_plot <- data_plot %>%
    mutate(participant = as.factor(!!participant_col))

  # get n of participants for plotting purposes
  num_unique <- data_plot %>%
    pull(!!participant_col) %>%
    unique() %>% length()

  ggplot(data_plot, aes(x = !!sym('day'),
                        y = !!sym('response_rate'),
                        group = !!sym('participant'),
                        color = !!sym('participant'),
                        shape = !!sym('participant'),
                        linetype = !!sym('participant'))) +
    ggplot2::geom_line() +
    ggplot2::geom_point() +
    ggplot2::scale_linetype_manual(values = rep(c("solid", "dashed", "dotted"),
                                                length.out = num_unique)) +
    ggplot2::scale_shape_manual(values = rep(c(3, 8, 15, 16, 17, 18),
                                             length.out = num_unique)) +
    ggplot2::labs(title = "Response rate per day",
         x = "Date",
         y = "Response rate")
}

# Function to calculate response rate per day.
response_rate_per_day <- function(data,
                                  valid_col,
                                  participant_col,
                                  time_col){

  time_col <- enquo(time_col)
  participant_col <- enquo(participant_col)
  valid_col <- enquo(valid_col)

  # Defining day and day1 before
  # to avoid warning 'no visible binding for global variable'
  day <- NULL
  day1 <- NULL

  data_plot <- data %>%
    # get day number from date
    group_by(!!participant_col) %>%
    # get the first day of the participant
    mutate(day1 = as.Date(min(!!time_col, na.rm=TRUE)),
           # calculate the number of days since the first beep was sent
           day = as.integer(difftime(as.Date(!!time_col), day1,
                                     units="days") + 1)) %>%
    # unselect the column day1, we just created it to calculate day_n
    select(-day1) %>%
    ungroup() %>%
    group_by(day, !!participant_col) %>% # group by day and participant
    # calculate response rate
    summarize(response_rate = sum(!!valid_col) / n()) %>%
    ungroup()

  return(data_plot)
}

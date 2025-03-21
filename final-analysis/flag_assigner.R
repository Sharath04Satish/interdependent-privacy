setwd("/Users/sharathsatish/Projects/interdependent-privacy/")

library(tidyverse)

data <- read_csv('./datasets/dataset_ip_addr_flag.csv')
data <- data %>% slice(-c(1, 2))

# Check if the values provided for age, and year of birth are the same for 
# each user.
age <- data %>% pull(age) %>% as.integer()
yob <- data %>% pull(yob_1) %>% as.integer()
current_year <- as.integer(format(Sys.Date(), "%Y"))
age_year_flag <- logical(length(yob))

for (idx in 1:length(yob)) {
  calc_age <- current_year - yob[[idx]]
  if (!is.na(calc_age)) {
    if (calc_age >= (age[[idx]] - 1) && calc_age <= (age[[idx]] + 1)) {
      age_year_flag[[idx]] <- FALSE
    }
    else {
      age_year_flag[[idx]] <- TRUE
    }
  } 
}

# Check user's language to be EN.
lang <- data %>% pull(UserLanguage)
lang_flag <- logical(length(lang))
for (idx in 1:length(lang)) {
  if (!is.na(lang[[idx]]) && lang[[idx]] == "EN") {
    lang_flag[[idx]] <- FALSE
  }
  else {
    lang_flag[[idx]] <- TRUE
  }
}

# Check if user's submission times per section is above median / 3.
timings <- data %>% select(all_of(c('timing_consent_Page Submit', 
                                    'timing_commitment_Page Submit',
                                    'timing_screening_Page Submit',
                                    'timing_privacy_Page Submit',
                                    'timing_usage_Page Submit'))) %>%
  mutate_all(as.numeric)
gen_timings_flag <- logical(dim(timings)[[1]])
total_timings <- rep(0, length(gen_timings_flag))
for (idx in 1:length(gen_timings_flag)) {
  if (all(!is.na(timings[idx, ]))) {
    total_timings[[idx]] <- sum(timings[idx, ], na.rm = T)
  }
}

med_total_timings <- median(total_timings[total_timings != 0])
for (idx in 1:length(gen_timings_flag)) {
  if (total_timings[[idx]] != 0) {
    if (total_timings[[idx]] >= med_total_timings / 3) {
      gen_timings_flag[[idx]] <- FALSE
    }
    else {
      gen_timings_flag[[idx]] <- TRUE
    }
  }
}

ph_persons <- data %>% pull('timing_photosperson_Page Submit') %>% as.integer()
ph_non_persons <- data %>% pull('timing_photosnon_Page Submit') %>% as.integer()
cn_persons <- data %>% pull('timing_contactperson_Page Submit') %>% as.integer()
cn_non_persons <- data %>% pull('timing_contactnon_Page Submit') %>% as.integer()
cl_persons <- data %>% pull('timing_calendarperso_Page Submit') %>% as.integer()
cl_non_persons <- data %>% pull('timing_calendarnon_Page Submit') %>% as.integer()
fl_persons <- data %>% pull('timing_fileperson_Page Submit') %>% as.integer()
fl_non_persons <- data %>% pull('timing_filenon_Page Submit') %>% as.integer()

med_ph_persons <- median(ph_persons[!is.na(ph_persons)])
med_ph_non_persons <- median(ph_non_persons[!is.na(ph_non_persons)])
med_cn_persons <- median(cn_persons[!is.na(cn_persons)])
med_cn_non_persons <- median(cn_non_persons[!is.na(cn_non_persons)])
med_cl_persons <- median(cl_persons[!is.na(cl_persons)])
med_cl_non_persons <- median(cl_non_persons[!is.na(cl_non_persons)])
med_fl_persons <- median(fl_persons[!is.na(fl_persons)])
med_fl_non_persons <- median(fl_non_persons[!is.na(fl_non_persons)])

scenario_timings_flag <- logical(length(ph_persons))
for (idx in 1:length(scenario_timings_flag)) {
  if (!is.na(ph_persons[[idx]])) {
    if (ph_persons[[idx]] >= med_ph_persons / 3) {
      scenario_timings_flag[[idx]] <- FALSE
    }
    else {
      scenario_timings_flag[[idx]] <- TRUE
    }
  }
  else if (!is.na(ph_non_persons[[idx]])) {
    if (ph_non_persons[[idx]] >= med_ph_non_persons / 3) {
      scenario_timings_flag[[idx]] <- FALSE
    }
    else {
      scenario_timings_flag[[idx]] <- TRUE
    }
  }
  else if (!is.na(cn_persons[[idx]])) {
    if (cn_persons[[idx]] >= med_cn_persons / 3) {
      scenario_timings_flag[[idx]] <- FALSE
    }
    else {
      scenario_timings_flag[[idx]] <- TRUE
    }
  }
  else if (!is.na(cn_non_persons[[idx]])) {
    if (cn_non_persons[[idx]] >= med_cn_non_persons / 3) {
      scenario_timings_flag[[idx]] <- FALSE
    }
    else {
      scenario_timings_flag[[idx]] <- TRUE
    }
  }
  else if (!is.na(cl_persons[[idx]])) {
    if (cl_persons[[idx]] >= med_cl_persons / 3) {
      scenario_timings_flag[[idx]] <- FALSE
    }
    else {
      scenario_timings_flag[[idx]] <- TRUE
    }
  }
  else if (!is.na(cl_non_persons[[idx]])) {
    if (cl_non_persons[[idx]] >= med_cl_non_persons / 3) {
      scenario_timings_flag[[idx]] <- FALSE
    }
    else {
      scenario_timings_flag[[idx]] <- TRUE
    }
  }
  else if (!is.na(fl_persons[[idx]])) {
    if (fl_persons[[idx]] >= med_fl_persons / 3) {
      scenario_timings_flag[[idx]] <- FALSE
    }
    else {
      scenario_timings_flag[[idx]] <- TRUE
    }
  }
  else if (!is.na(fl_non_persons[[idx]])) {
    if (fl_non_persons[[idx]] >= med_fl_non_persons / 3) {
      scenario_timings_flag[[idx]] <- FALSE
    }
    else {
      scenario_timings_flag[[idx]] <- TRUE
    }
  }
}

timings_flag <- gen_timings_flag & scenario_timings_flag

# Attention checks
# likertscale_help_6, attentioncheck_2
at_check1 <- data %>% pull(likertscale_help_6)
at_check1_flag <- logical(length(at_check1))
at_check1_flag[at_check1 == "Somewhat Disagree"] <- FALSE
at_check1_flag[at_check1 != "Somewhat Disagree"] <- TRUE
at_check2 <- data %>% pull(attentioncheck_2) %>% as.integer()
at_check2_flag <- logical(length(at_check2))
at_check2_flag[at_check2 == 7] <- FALSE
at_check2_flag[at_check2 != 7] <- TRUE

attention_check_flag <- at_check1_flag & at_check2_flag

# Detecting patterns in responses
likhert_data <- data %>% select(
  all_of(c('thomashimself_1', 'thomashimself_2', 'thomashimself_3',
           'thomasfriend_1', 'thomasfriend_2', 'thomasfriend_3',
           'thomasresponsibility_1', 'thomasresponsibility_2',
           'privacysensitivity_1', 'privacysensitivity_2',
           'privacysensitivity_3', 'privacysensitivity_4',
           'privacysensitivity_5', 'privacysensitivity_6',
           'privacysensitivity_7', 'privacysensitivity_8',
           'likertscale_help_1', 'likertscale_help_2',
           'likertscale_help_3', 'likertscale_help_4',
           'likertscale_help_5', 'likertscale_help_6',
           'likertscale_help_7', 'likertscale_help_8',
           'likertscale_help_9', 'likertscale_help_10',
           'personalinformation_1', 'personalinformation_2',
           'personalinformation_3', 'personalinformation_4',
           'friendinformation_1', 'friendinformation_2',
           'friendinformation_3', 'friendinformation_4',
           'photo_option_1', 'photo_option_2', 
           'contact_option_1', 'contact_option_2',
           'calendar_option_1', 'calendar_option_2', 
           'file_option_1', 'file_option_2',
           'photo_option_flip_1', 'photo_option_flip_1', 
           'calendar_option_flip_1', 'file_option_flip_1'))
)

no_responses_flag <- likhert_data %>%
  rowwise() %>%
  mutate(all_na = all(is.na(c_across(everything())))) %>% pull(all_na)

same_responses_flag <- likhert_data %>%
  rowwise() %>%
  mutate(all_same = length(unique(na.omit(c_across(everything())))) == 1) %>%
  pull(all_same)

# Aggregate all flag values to the dataset.
data <- data %>%
  mutate(age_year_flag = age_year_flag,
         lang_flag = lang_flag, 
         timings_flag = timings_flag,
         attention_check_flag = attention_check_flag,
         no_responses_flag = no_responses_flag,
         same_responses_flag = same_responses_flag)

write_csv(data, "./datasets/dataset_all_flags.csv")


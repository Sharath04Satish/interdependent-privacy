# Interdependent Privacy

The file structure for this project is presented as,
- ./datasets - Contains participant survey data, along with additional files to analyze their responses.
- ./prelim-analysis - Contains analysis done on the preliminary responses.
- ./final-analysis - Contains analysis done on the current responses from Amazon MTurk.

### Determining if participants are from the US
- In order to determine if the participants are responding to their surveys from the US, the IP address of the participant recorded is queried against the ./datasets/GeoLite2-Country.mmdb file. 
- To download the file, visit [P3TERX's GitHub repository](https://github.com/P3TERX/GeoLite.mmdb/releases).

### Description of Flags
By default, all flags are marked TRUE if they violate the condition being evaluated, and FALSE otherwise.

1. **IP Address Flag** - Evaluates if the IP address of the participant while answering this survey corresponds to the US. The GeoLite database is used to determine the base location of the participant.

2. **Correlation with age and year of birth** - Evaluates if the participants age based on the year of birth is in the range [age - 1, age + 1], and checks if they are at least 18 years old.

3. **Language Preference** - Evaluates if the participants' language of choice to answer the survey is EN (English).

4. **Time to Complete Survey** - Calculates the total time taken by participants to complete the survey, while separately calculating the time taken to complete the individual scenarios randomly assigned to them. The median of the time taken to complete the common questions is calculated to evaluate if participants answered the survey before median / 3 time. The same evaluation is assigned to scenario sections, which measures the median time based on that scenario alone. Finally, both the flags are combined using a logical AND operation.

5. **Attention checks** - Evaluates participants' responses to the two attention check questions presented in the survey and uses the logical AND operation to combine the flag values.

6. **Detecting patterns in responses** - Firstly, this evaluates if participants skipped all the questions based on likhert scale. Next, evaluates if participants selected the same option for all the likhert scale questions.
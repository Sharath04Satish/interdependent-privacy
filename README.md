# Interdependent Privacy

The file structure for this project is presented as,
- ./datasets - Contains participant survey data, along with additional files to analyze their responses.
- ./prelim-analysis - Contains analysis done on the preliminary responses.
- ./final-analysis - Contains analysis done on the current responses from Amazon MTurk.

### Determining if participants are from the US
- In order to determine if the participants are responding to their surveys from the US, the IP address of the participant recorded is queried against the ./datasets/GeoLite2-Country.mmdb file. 
- To download the file, visit [P3TERX's GitHub repository](https://github.com/P3TERX/GeoLite.mmdb/releases).
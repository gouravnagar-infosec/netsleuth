### NetSleuth: Advanced IP Intelligence Gatherer (Interactive Edition)

#### Description
NetSleuth is an interactive Bash script designed for advanced IP intelligence gathering. It processes input files to extract, filter, and analyze IP addresses, providing detailed information about each IP address using the `ipinfo.io` API. The script offers functionalities to display or save the results in a user-friendly format. 

#### Features
- **Interactive Menu**: Allows users to add input files, set API tokens, specify output files, and run the analysis.
- **IP Extraction**: Extracts and deduplicates IP addresses from the specified input files.
- **Filtering**: Filters out private and reserved IP addresses to focus on public IPs.
- **API Integration**: Fetches detailed information for each IP address from the `ipinfo.io` API.
- **Progress Bar**: Displays a progress bar while fetching data.
- **Output Options**: Results can be printed to the console or saved to a specified file.

#### Usage
1. **Run the script**: Execute the script in your terminal.
   ```bash
   ./NetSleuth.sh
   ```
2. **Interactive Menu**:
   - **Add input file**: Specify the filename containing IP addresses.
   - **Set API token**: Enter your `ipinfo.io` API token (optional).
   - **Set output file**: Specify the filename to save the output.
   - **Run analysis**: Start the IP analysis process.
   - **Exit**: Exit the script.

#### Example
```bash
./NetSleuth.sh
```

#### Dependencies
- `bash`
- `curl`
- `jq`

#### Notes
- Ensure the input files contain IP addresses.
- The API token is optional but recommended for higher request limits.
- The output file path should be writable if specified.

#### License
This project is licensed under the MIT License.

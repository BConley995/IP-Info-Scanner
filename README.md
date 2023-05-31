# Software Information

This repository contains a PowerShell script for gathering information about the software running on a computer.

## Script Description

The PowerShell script is designed to identify different software based on specific files or directories present on the system. It retrieves various information such as IP addresses, server details, DNS servers, MAC address, and more, depending on the software identity.

## Usage

To use the script, follow these steps:

1. Clone the repository or download the PowerShell script.

2. Open PowerShell or any compatible PowerShell environment.

3. Navigate to the directory where the script is located.

4. Run the script using the following command:
```shell
PowerShell -ExecutionPolicy Bypass -File SoftwareInfo.ps1
```

Note: Ensure that you have appropriate permissions to execute PowerShell scripts on your system.

5. The script will identify the software running on your computer and gather relevant information. The gathered information will be displayed in the console.

## Software Identities

The script can identify the following software:

- **Detached** (Version 1 and Version 2)
- **Helicopter** (Version 1 and Version 2)
- **BC** (Version 1 and Version 2)
- **Indigo** (Version 1 and Version 2)
- **Elephant**

For each software identity, specific information will be gathered and displayed.

## Requirements

- PowerShell (compatible with PowerShell 5.1 or later)

## License

This script is licensed under the [MIT License](LICENSE).

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

## Disclaimer

The script provided here is for informational purposes only. Use it at your own risk. The author is not responsible for any damages or issues caused by using this script.

## Table of Contents
- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Contributing](#contributing)
- [License](#license)

## Getting Started
The noninvasive, real-time bloodflow monitoring system at Openwater employs the phase-wave laser speckle contrast imaging technique with unprededented depth and blood flow velocity fidelity.
This imaging approach requires an illumination system (a pulsed highly coherent infrared laser) and the detection system (a high QE in the infrared camera with pixel sizes close to wavelength of light). A holographic speckle pattern comprises bright and dark spots that arise due to the interference of multiple backscatterd light from scattering medium (biological tissue). The quality of speckle image depends on the coherence and the stablility of the laser used in the system. Therefore, the test protocol for the coherence and the stability is explained in details in the document "Laser Characterization and Qualification" in wiki.

## wiki - Laser Characterization and Qualification:
This document in wiki contains the information regarding the laser system used in Openwater bloodflow monitoring units. It explains the requirements for the laser systems, discusses the techincal issues, the tests and characterizations performed at Openwater laboratories to qualify the laser system.

## files located in repo:

 This provides the final test procedure performed on the laser system with direct speckle contrast measruements to qualify the laser.
  
* interferometer_chirp_test_sample_data.mat

* interferometer_chirp_test.m

* XIMEA_Speckle_Contrast_7.lua

## Prerequisites

Various sensitive optical equipment are needed to build the blood flow device and evaulate the quality of the laser illumination required. See repo for test and calibration equipment and procedure.

## Contributing

We welcome contributions from the community. If you have ideas for improvements or find any issues, please open an issue or submit a pull request.

Before contributing, please read our [Contributing Guidelines](CONTRIBUTING.md).

## License

opw_laser is licensed under the GNU Affero General Public License v3.0. See [LICENSE](LICENSE) for details.

## Investigational Use Only
CAUTION - Investigational device. Limited by Federal (or United States) law to investigational use. opw_laser has *not* been evaluated by the FDA and is not designed for the treatment or diagnosis of any disease. It is provided AS-IS, with no warranties. User assumes all liability and responsibility for identifying and mitigating risks associated with using this software.


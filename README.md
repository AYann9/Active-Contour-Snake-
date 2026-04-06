# Active Contour Image Segmentation
> Comparison and Analysis of Snake, GVF-Snake, and HLFRA Models

## Overview
This project implements and compares three classic **active contour (Active Contour)** methods for image segmentation:
- Traditional Snake Model
- GVF-Snake Model (Gradient Vector Flow)
- HLFRA Model (Hybrid Local Fuzzy Region-Active Contour)

We focus on performance in **medical images, intensity inhomogeneity, noise, complex shapes, and multi-target segmentation**.

## Key Features
- Mathematical derivation and numerical accuracy analysis of Snake model
- Parameter sensitivity study (α, β, γ)
- Comparison of convergence speed and robustness
- Suitable for medical imaging and computer vision tasks

## Models
### 1. Snake Model
- Parametric active contour based on energy minimization
- Internal energy: elasticity & rigidity
- External energy: image gradient
- Numerical scheme: central difference + Crank-Nicolson iteration

### 2. GVF-Snake Model
- Improved external force field
- Better capture range and concave region segmentation
- Still edge-dependent

### 3. HLFRA Model
- Hybrid region-edge driven active contour
- Robust to noise and intensity inhomogeneity
- Supports fast multi-target segmentation
- Based on level-set framework

## Performance Comparison
| Model       | Initial Sensitivity | Intensity Inhomogeneity | Multi-target | Speed  |
|-------------|---------------------|-------------------------|--------------|--------|
| Snake       | High                | Poor                    | ❌           | Medium |
| GVF-Snake   | Medium              | Medium                  | ⚠️ Limited   | Medium |
| HLFRA       | Low                 | Excellent               | ✅           | Fast   |

## Usage
1. Clone this repository
2. Run main scripts in MATLAB/Python
3. Adjust parameters: `alpha`, `beta`, `gamma`, `num_points`
4. Compare segmentation results and energy curves

## Applications
- Medical image segmentation (skin lesions, tissues)
- Object detection and tracking
- Edge extraction in natural images

## Requirements
- MATLAB / Python 3.x
- NumPy, Matplotlib, OpenCV
- Image Processing Toolbox

## License
MIT

# GreeceGDPAnalysis
A complete analytical pipeline for simple time series analysis, tested and trained on rGDP data of Greece from FRED

## Requirements

- Docker

## Setup

### Using Docker

1. **Clone the repository**:
    ```sh
    git clone https://github.com/aleksandrafrania/diabetes_pipeline.git
    cd diabetes_pipeline
    ```

2. **Build the Docker image**:
    ```sh
    docker build -t diabetes_pipeline .
    ```

3. **Run the Docker container**:
    ```sh
    docker run -it --rm diabetes_pipeline
    ```

## Project Structure

- `utils/`: Folder containing utility functions.
  - `data_exploration.py`: Functions for data exploration.
  - `data_cleaning.py`: Functions for data cleaning.
  - `prediction_model.py`: Functions for model training and evaluation.
- `main.py`: Main script to run the pipeline.
- `requirements.txt`: Python dependencies.
- `Dockerfile`: Docker configuration.

## Usage

The pipeline will load the dataset, perform data cleaning, train the model, and provide a visual comparison. The resulting graph will be saved as a PDF file.

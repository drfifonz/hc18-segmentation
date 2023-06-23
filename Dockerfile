FROM pytorch/pytorch:latest

# ENV PATH="/root/miniconda3/bin:${PATH}"
# ARG PATH="/root/miniconda3/bin:${PATH}"

RUN apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*


RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 
# 
# Install miniconda
ENV CONDA_DIR /root/.conda
# RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
#     /bin/bash ~/miniconda.sh -b -p /opt/conda

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH

RUN conda --version
RUN conda install mamba -n base -c conda-forge
RUN mamba --version

# create working direcotyry
WORKDIR /app
# create mamba env and activate it
COPY environment.yml /tmp/environment.yml
RUN mamba env create -f /tmp/environment.yml && mamba clean -ya
RUN mamba init; 
# RUN source ~/.bashrc
RUN echo "mamba activate pymic" >> ~/.bashrc
ENV PATH /opt/conda/envs/pymic/bin:$PATH
# RUN pip install 'dvc[ssh]' paramiko
# RUN useradd -r -u 111 jenkins



# copy source code
COPY src ./src
COPY config ./config
COPY hc18-unet.ipynb ./hc18-unet.ipynb

# make download dataset
RUN mkdir -p ./data
RUN wget https://zenodo.org/record/1327317/files/training_set.zip -O ./data/training_set.zip
RUN wget https://zenodo.org/record/1327317/files/test_set.zip -O ./data/test_set.zip
RUN unzip ./data/training_set.zip -d ./data
RUN unzip ./data/test_set.zip -d ./data

CMD echo "Hello World"
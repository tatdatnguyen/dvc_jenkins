# Use an official PyTorch image as a base
FROM pytorch/torchserve:latest-cpu

# Switch to root user to install dependencies
USER root

# Set working directory
WORKDIR /home/model-server/

# Install Git and DVC dependencies
RUN apt-get update && apt-get install -y git && pip install --no-cache-dir dvc[s3]
COPY BERTSeqClassification.mar.dvc /home/model-server/
# Copy the .dvc directory and .git directory into the container
COPY .dvc /home/model-server/.dvc
COPY .git /home/model-server/.git  
# Ensure git configuration is included

# Install Python dependencies from requirements.txt (if needed)
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Create model store directory
RUN dvc pull
RUN mv BERTSeqClassification.mar /home/model-server/model-store
EXPOSE 8080 8081 
# Command to pull the model from DVC and start TorchServe
CMD ["torchserve", "--start", "--model-store", "model-store", "--models", "BERTSeqClassification=BERTSeqClassification.mar", "--ncs", "--disable-token-auth", "--enable-model-api"]
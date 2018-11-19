# Batch Shipyard Quickstart
Choose your speed:

1. [Notebooks](#notebooks)
2. [Normal Quickstart](#normal)
3. [Ludicrous Speed Quickstart](#ludicrous)

## <a name="notebooks"></a>Notebooks
If you are interested in executing Deep Learning workloads on Batch Shipyard
and want to jump in without having to install anything, you can utilize the
[Deep Learning Jupyter Notebooks](https://github.com/Azure/batch-shipyard/blob/master/contrib/notebooks/deep_learning)
on [Azure Notebooks](https://notebooks.azure.com/) to quickly get started.

## <a name="normal"></a>Normal Quickstart
If you would like to use Batch Shipyard from the command line, this quickstart
doc will provide step-by-step instructions. Although Batch Shipyard
supports any type of Batch processing or HPC workload, for the following
quickstart guide, we will select from the following Deep Learning recipes
as an example workflow:

* [CNTK-CPU-OpenMPI](https://github.com/Azure/batch-shipyard/blob/master/recipes/CNTK-CPU-OpenMPI)
* [Caffe-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/Caffe-CPU)
* [Caffe2-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/Caffe2-CPU)
* [Chainer-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/Chainer-CPU)
* [Keras+Theano-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/Keras+Theano-CPU)
* [MXNet-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/MXNet-CPU)
* [PyTorch-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/PyTorch-CPU)
* [TensorFlow-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/TensorFlow-CPU)
* [Torch-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/Torch-CPU)

The example MNIST training sample will be used on one Azure Batch compute node
regardless of which Deep Learning framework you prefer for the following.
Note that this quickstart guide focuses on Docker container execution but
the commands are agnostic to which containers (Docker or Singularity) you
are using - only the configuration changes with respect to which ecosystem
you are using.

1. [Installation of Batch Shipyard](01-batch-shipyard-installation.md)
to your local machine has been completed or you are using Batch Shipyard
from within Azure Cloud Shell.
2. Create a directory to hold your configuration files. For this quickstart
guide, create a directory named `config`.
3. Copy the sample configuration files from the Deep Learning framework recipe
of your choice to the `config` directory:
    * [CNTK-CPU-OpenMPI](https://github.com/Azure/batch-shipyard/blob/master/recipes/CNTK-CPU-OpenMPI/config/singlenode/)
    * [Caffe-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/Caffe-CPU/config/)
    * [Caffe2-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/Caffe2-CPU/config/)
    * [Chainer-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/Chainer-CPU/config/)
    * [Keras+Theano-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/Keras+Theano-CPU/config/)
    * [MXNet-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/MXNet-CPU/config/singlenode/)
    * [PyTorch-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/PyTorch-CPU/config/)
    * [TensorFlow-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/TensorFlow-CPU/config/)
    * [Torch-CPU](https://github.com/Azure/batch-shipyard/blob/master/recipes/Torch-CPU/config/)
4. Edit the `config/credentials.yaml` file and populate it with your Azure
Batch and Azure Storage credentials. If you do not have an Azure Batch account,
you can create one via the
[Azure Portal](https://azure.microsoft.com/documentation/articles/batch-account-create-portal/),
[Azure CLI 2.0](https://docs.microsoft.com/cli/azure/install-azure-cli), or
[Azure PowerShell](https://azure.microsoft.com/documentation/articles/batch-powershell-cmdlets-get-started/).
You can create a standard general purpose
[Azure Storage account](https://docs.microsoft.com/azure/storage/storage-create-storage-account#create-a-storage-account)
using any of the aforementioned methods similar to creating an Azure Batch
account.
5. Edit the `config/config.yaml` file and edit the following settings:
    * `storage_account_settings` to link to the storage account named in step 4.
6. In the main `batch-shipyard` directory (which should contain the
`shipyard` or `shipyard.cmd` helper scripts if on Linux or Windows,
respectively), run the following commands:
```shell
# change working directory to the config directory
cd config

# create the compute pool
# NOTE: if you are on Windows, use ..\shipyard.cmd instead of ../shipyard
../shipyard pool add

# ... wait for pool to allocate ...

# add the training job and tail the output
# if CNTK-CPU-OpenMPI, Caffe2-CPU, Chainer-CPU, Keras+Theano-CPU, MXNet-CPU, TensorFlow-CPU, or Torch-CPU
../shipyard jobs add --tail stdout.txt
# if Caffe-CPU
../shipyard jobs add --tail stderr.txt
```
The `--tail` option of the `jobs add` command will stream the stderr or stdout
file to your local console which will provide you progress information about
your job.

Once you are finished interacting with your jobs, tasks and pool, you can
remove them with the following commands:
```shell
# after you are done interacting with jobs/tasks/pool
../shipyard jobs del --wait
../shipyard pool del
```

## <a name="ludicrous"></a>Ludicrous Speed Quickstart
Pre-jump checklist:

* Linux, Mac or WSL machine with network access
* `git` and Python3 is installed
* Comfortable with Linux commandline
* Have an active Azure subscription
* Understand how to use the Azure Portal

Spin up FTL drives:

1. [Create Batch account](https://portal.azure.com/#create/Microsoft.BatchAccount) if you do not have one
2. [Retrieve the Batch account key and service URL](https://portal.azure.com/#blade/HubsExtension/Resources/resourceType/Microsoft.Batch%2FbatchAccounts)
3. [Create Storage account](https://portal.azure.com/#create/Microsoft.StorageAccount-ARM) if you do not have one
4. [Retrieve the Storage account key](https://portal.azure.com/#blade/HubsExtension/Resources/resourceType/Microsoft.Storage%2FStorageAccounts)

Execute jump:
```shell
git clone https://github.com/Azure/batch-shipyard.git
cd batch-shipyard
./install.sh
export SHIPYARD_CONFIGDIR=recipes/TensorFlow-CPU/config
nano $SHIPYARD_CONFIGDIR/credentials.yaml
# edit required properties in file and save
./shipyard pool add
./shipyard jobs add --tail stdout.txt
```

Jump complete:
```shell
# clean up
./shipyard jobs del -y --wait
./shipyard pool del -y
unset SHIPYARD_CONFIGDIR
```

## Step-by-step Tutorial
The [From Scratch: Step-by-step](05-batch-shipyard-from-scratch-step-by-step.md)
guide will provide detailed steps on how to construct your own set of
configuration files to execute on Batch Shipyard.

## Commandline Usage Guide
[Batch Shipyard Usage](20-batch-shipyard-usage.md) contains explanations for
all of the actions available with commandline interface.

## In-Depth Configuration Guide
It is recommended to review the full
[in-depth configuration guide](10-batch-shipyard-configuration.md) for
explanations of all of the configuration options available for Batch Shipyard.

## Graphical Interfaces
You can also use the [Azure Portal](https://portal.azure.com) or
[Batch Labs](https://github.com/Azure/BatchLabs) to
view more properties of your Azure Batch accounts, pools, nodes, jobs and
tasks. You can view your Azure Storage accounts on Azure Portal or with
[Microsoft Azure Storage Explorer](http://storageexplorer.com/).

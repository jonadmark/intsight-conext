# IntSight (CoNEXT 2020)

This repository is the central hub for all code and artifacts of the CoNEXT 2020 paper entitled "IntSight: Diagnosing SLO Violations with In-Band Network Telemetry"

## 1. Setup

Follow the next steps to setup an experimental environment to reproduce the experiments. Our artifacts were build for and tested on Ubuntu 16.04. We recommend using this release of Ubuntu since it is the most suitable for the P4 environment. We also recommend starting from a clean install and setting up the environment on a baremetal machine (as opposed to a virtual machine).

Starting by cloning this repository with the following command to ensure all submodules are cloned along with it:

```
git clone --recurse-submodules https://github.com/jonadmark/intsight-conext.git
```

Then navigate to the directory where the repository was cloned and install the base dependencies. On a terminal run:

```
cd intsight-conext
sudo bash install_basedeps.sh
```

Next, install the P4 environment with the following command. This may take a while to run depending on the machine resources. In our experience, it takes from about one to three hours for the script to install the P4 environment.

```
bash install_p4env.sh
```

Install a Python3 environment using the Conda open source package management system and environment management system. Make sure to opt-in for initializing and auto activating Conda when prompted during the installation process.

```
bash install_conda.sh
```

After the installation, Conda will work on all newly initiated terminal sessions. Close the session you are using and start a new one. Finally, install the necessary Python3 libraries with the following command.

```
bash install_python3libs.sh
```

The environment is all set for running the experiments!

## 2. Reproducing the Functional Evaluation

The directory containing the artifacts to reproduce the functional evaluation is `intsight-funceval/intsight-bmv2`. Before we can run the experiments, we first need to generate the pcap packet traces used for both of our use cases. Execute the following commands to navigate to the directory with configuration and scripts files for the end-to-end delay use case, and then generate the necessary pcaps.

```
cd intsight-funceval/intsight-bmv2/experiments/e2edelay
python3 genpcaps.py
```

Then, similarly, navigate to the directory for the bandwidth use case and generate the necessary pcaps.

```
cd ../bandwidth
python3 genpcaps.py
```

Next, run the end-to-end delay experiment. First, navigate back to the root directory for the functional evaluation `intsight-funceval/intsight-bmv2` and then launch the experimentation script.

```
cd ../..
bash experiment.sh experiments/e2edelay/network.json
```

Wait until the experiment ends, it should take no more than two minutes. Next, create a directory to store the obtained results and copy the files and directories necessary for running the analysis and generating the paper figures.

```
mkdir experiments/e2edelay/my_results
cp configure.py /experiments/e2edelay/my_results/
cp -r logs /experiments/e2edelay/my_results/
```

Generate the paper figures using the provided Jupyter Notebook. Open the notebook with the following command.

```
cd experiments/e2edelay/
jupyter notebook genfigures.ipynb
```

The command above will open a browser window and show the notebook. It shows a snapshot of the results presented in the paper. To reproduce the results, change the line `exp_dir = './paper_results/'` to `exp_dir = './my_results'` so that the analysis will consider the new results. Next, in the browser window, open the `Kernel` menu and click on `Restart & Run All`. This will run the notebook and generate all figures for the end-to-end delay use case.

> **Note**: The functional experiments are based on the P4 software switch, which has performance as a non-goal. As previously metioned, for best results, install and run the experiments baremetal on a well provisioned machine. For the paper, we ran our experiments on a dedicated Ubuntu 16.04 (Linux 4.4) server with 2x Intel Xeon Silver 4208 2.1 GHz 8-core 16-thread processors, 8x 16 GB 2400 MHz RAM, and 2 TB of NVMe SSD storage.

Next, we list the necessary steps to reproduce the bandwidth use case, which are basically the same as the ones for the end-to-end delay use case.

```
cd ../..
bash experiment.sh experiments/bandwidth/network.json
mkdir experiments/bandwidth/my_results
cp configure.py /experiments/bandwidth/my_results/
cp -r logs /experiments/bandwidth/my_results/
cd experiments/bandwidth/
jupyter notebook genfigures.ipynb
```

Similarly to before, the last command will open a browser window and show the notebook. It shows a snapshot of the results presented in the paper. To reproduce the results, change the line `exp_dir = './paper_results/'` to `exp_dir = './my_results'` so that the analysis will consider the new results. Next, in the browser window, open the `Kernel` menu and click on `Restart & Run All`. This will run the notebook and generate all figures for the end-to-end delay use case.

Congratulations! You are all done with reproducing the functional evaluation.

## 3. Reproducing the Performance Evaluation

The performance evaluation is based on analytical models of IntSight and the related approaches. To run the evaluation we first need to convert the network topologies and demands from their textual descriptions (made available by the Repetita project) to json files readily readable by the evaluation Jupyter notebook. On a terminal window at the root directory of this repository, run:

```
cd intsight-perfeval
python3 repetita2json.py
```

After the conversion is done, the notebook can be opened with the following command:

```
jupyter notebook performance-evaluation.ipynb
```

The command above will open a browser window and show the notebook. Initially, it shows a snapshot of the results presented in the paper. To reproduce the results, in the browser window, open the `Kernel` menu and click on `Restart & Run All`. This will run the notebook and generate all figures. This notebook takes several minutes to run. When all notebook cells have been run, all figures and results will be available throughout the notebook as well as in subdirectory `paper_results`.

Congratulations! You are all done with reproducing the performance evaluation.

## 4. Reusing our artifacts for your own experiments

Our artifacts were built in a way that enables them to be reused for other purposes and additional experiments. Here we present a few pointers to guide anyone interested in adjusting or extending our artifacts.

### 4.1 Reusing the Functional Evaluation Artifacts

The main file of a functional experiment is the `network.json` file. Following we present the contents of this file for the end-to-end delay use case and describe each parameter.

```
{
    "capture_traffic": false,
    "run_workload": true,
    "workload_file": "experiments/e2edelay/workload.json",
    "nodes": 5,
    "hosts_per_node": 2,
    "node_links": [
        ["s3", "s4"],
        ["s3", "s2"],
        ["s4", "s5"],
        ["s2", "s1"]
    ],
    "e2e_delay_slas": {
        "h1": {
            "h10": [20000, 1]
        }
    }
}
```

- `capture_traffic`: indicates if the network traffic should be captured during the execution of the experiment. Ideally `false` to help maximize the performance, but can be set to `true` to help debug problems.
- `run_workload`: indicates if Mininet should run the workload (as described by `workload_file`) or simply build the emulated network and present a command prompt to the user. Can be set to `false` if you want to interactively generate traffic and do tests.
- `workload_file`: a json file that describes the workload of the experiment.
- `nodes`: the number of forwarding nodes in the network topology.
- `hosts_per_node`: how many hosts should be created (and connected) to each forwarding node.
- `node_links`: list of links between forwarding nodes in the network topology.
- `e2e_delay_slas`: end-to-end delay SLA specifications. In the example, the delay between host `h1` to host `h10` cannot be greater or equal to 20 milliseconds (first value, delay < 20000 microseconds) for any packet (second value, number of high delayed packets < 1).

The workload of an experiment can be adjusted by modifying (and running) the `genpcaps.py` script. The main element to modify are the `Y` functions that return a bitrate as a function of experiment time. For example, in the `genpcaps.py` script of the end-to-end delay use case, the bitrate behavior of the orange flow is defined by:

```
def Yorange(x):
    if x >= 30 and x <= 30.1:
        return 106.632
    return 15*random.gauss(1, 0.1)
```

Between instants 30.0 and 30.1 seconds of the experiment, the rate is about 106 Mbps. The rest of the experiment the bitrate is about 15 Mbps. The term `random.gauss(1, 0.1)` is used to generate oscillations in traffic so that the rate is not completely constant.

Other important files to be aware of when modifying the functional evaluation artifacts.
- `intsight.p4`: This is the P4 program installed in the forwarding nodes of the network.
- `configure.py`: This script generates configuration files to be used during the experiment. Specially, it is responsible for parsing the `network.json` file into a Mininet topology description and generating P4 runtime rules to be installed into nodes during the experiment.
- `report-receiver.py`: Script that receives the IntSight reports sent by the forwarding nodes.

### 4.2 Reusing the Performance Evaluation Artifacts

The main file of the performance evaluation is the `performance-evaluation.ipynb` Jupyter notebook. The `1.2. Helper Functions` section of the notebook has a function to model the resource usage of each one of the evaluated approaches. For example, below we present the function that computes the resource usage for mirroring approaches (e.g., NetSight).

```
def Mirroring(net_json, net_graph, demands_json):
    # report rate
    pr = 0
    for d in demands_json['demands_list']:
        pr = pr + (d['pktrate']*nx.shortest_path_length(net_graph, d['src'], d['dst']))
    #
    return {
        'report_rate': pr,
        'sram_memory': 0,
        'tcam_memory': 0,
        'header_space': 0,
    }

```

Model functions receive as three objects as input. The first is a Python dictionary with metadata about the network for which one wants to estimate the resource usage. The second is a NetworkX graph that represents the network topology. The third is another dictionary with information regarding the bitrate demand between pairs of forwarding nodes in the network. Model functions return a Python dictionary with fields indicating resource usage. As the name implies, mirroring approaches simply configure devices to mirror to the control plane a copy of the packets they are forwarding. Consequently, they do not use header space or memory. The report rate is a function of the number of hops in the path of each packet in the network. For each node pair demand, we add to an accumulated variable `pr`, the packet rate multiplied by the path length between endpoints. New model functions could be added to analyze additional approaches.

Section 1.3. (i.e., Main Code), contains the main evaluation loop of the notebook. It applies each of the selected network topologies to the model functions and stores the results in a Pandas DataFrame (i.e., a table). This table can subsequently be queried to analyze the resource usage and generate figures, as we do in Section 2. Although the model functions and figure generation code in the notebook were built for the purpose of the performance evaluation, they could be swapped with other functions to be evaluated considering the network topologies available in the Repetita dataset.

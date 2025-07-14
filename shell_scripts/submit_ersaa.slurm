#!/bin/bash
#SBATCH --job-name=FI-SAA-job         # 作业名称
#SBATCH --output=log/main_out_%A_%a.txt   # 输出文件，%A 为作业 ID，%a 为数组索引
#SBATCH --error=log/main_err_%A_%a.txt    # 错误文件
#SBATCH --cpus-per-task=4             # 每任务 CPU 核心数
#SBATCH --time=0-12:00:00             # 最大运行时间（12小时，需根据任务调整）
#SBATCH --array=1-200%40             # 数组任务，1到200，限制同时运行40个任务
#SBATCH --export=ALL                  # 传递所有环境变量，类似 HTCondor 的 getenv=true

# 根据节点名称设置 GRB_LICENSE_FILE
if [ "$SLURM_NODELIST" == "gpu114" ]; then
    export GRB_LICENSE_FILE=/mnt/disk5/home/jinwang/gurobi.lic
elif [ "$SLURM_NODELIST" == "gpu115" ]; then
    export GRB_LICENSE_FILE=/mnt/disk5/home/jinwang/Gurobi_license/gurobi_node2.lic
fi


# 从 instances_case1.txt 读取参数
INPUT_FILE="../instances/instances_case1.txt"
TOTAL_LINES=$(wc -l < "$INPUT_FILE")
TASK_ID=$SLURM_ARRAY_TASK_ID

# 检查是否超出文件行数
echo "Task ID $TASK_ID"
echo "Total lines in $INPUT_FILE: $TOTAL_LINES"
if [ "$TASK_ID" -gt "$TOTAL_LINES" ]; then
    echo "Task ID $TASK_ID exceeds total lines ($TOTAL_LINES) in $INPUT_FILE. Exiting."
    exit 0  # 退出任务，不执行后续操作
fi

# 假设文件格式为每行：modRepNum degNum dataRepNum saaRepNum
PARAMS=($(sed -n "${SLURM_ARRAY_TASK_ID}p" $INPUT_FILE))

# 检查是否成功读取参数
if [ ${#PARAMS[@]} -ne 4 ]; then
    echo "Error: Failed to read parameters for task ${SLURM_ARRAY_TASK_ID}" >&2
    exit 1
fi

# 运行 Bash 脚本，传递参数
./shell_ersaa.sh ${PARAMS[0]} ${PARAMS[1]} ${PARAMS[2]} ${PARAMS[3]}
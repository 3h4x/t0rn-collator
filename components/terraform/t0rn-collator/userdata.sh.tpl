#!/bin/bash
export ROCOCO_BOOT_NODE=${rococo_boot_node}
export T0RN_BOOT_NODE=${t0rn_boot_node}
export NAME=${collator_name}

sudo yum install -y docker
sudo systemctl enable docker
sudo service docker start

docker run -dit --restart always ${image} --collator \
  --name $${NAME} \
  --chain /node/specs/t0rn.raw.json \
  --bootnodes "$T0RN_BOOT_NODE" \
  --port 33333 \
  --rpc-port 8833 \
  --prometheus-port 7001 \
  --telemetry-url 'wss://telemetry.polkadot.io/submit 1' \
  --ws-port 9933 \
  --execution Wasm \
  --pruning=archive \
  -- \
  --chain /node/specs/rococo.raw.json \
  --bootnodes "$ROCOCO_BOOT_NODE" \
  --port 10001 \
  --rpc-port 8001 \
  --ws-port 9001 \
  --execution Wasm
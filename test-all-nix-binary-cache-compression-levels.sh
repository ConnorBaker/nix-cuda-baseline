#!/usr/bin/env bash

set -euo pipefail

echo "Starting no compression..."
time nix run ".#pytorch-nix-binary-cache-size-none--1" 2>/dev/null
echo "Finished no compression."

echo "Starting BZIP..."
for i in {1..9}; do
    echo "Starting BZIP $i..."
    time nix run ".#pytorch-nix-binary-cache-size-bzip2-$i" 2>/dev/null
    echo "Finished BZIP $i."
done
echo "Finished BZIP."

echo "Starting GZIP..."
for i in {1..9}; do
    echo "Starting GZIP $i..."
    time nix run ".#pytorch-nix-binary-cache-size-gzip-$i" 2>/dev/null
    echo "Finished GZIP $i."
done

echo "Starting XZ..."
for i in {1..9}; do
    echo "Starting XZ $i..."
    time nix run ".#pytorch-nix-binary-cache-size-xz-$i" 2>/dev/null
    echo "Finished XZ $i."
done

echo "Starting ZSTD..."
for i in {1..19}; do
    echo "Starting ZSTD $i..."
    time nix run ".#pytorch-nix-binary-cache-size-zstd-$i" 2>/dev/null
    echo "Finished ZSTD $i."
done

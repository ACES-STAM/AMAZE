#!/usr/bin/env python3

import argparse
from pathlib import Path
import re
import subprocess


MAX_EDIT_DISTANCE = 10


def calc_levenshtein_distance(s1, s2):

    deletion_weight = 1
    insertion_weight = 1
    substitution_weight = 1

    n1 = len(s1)
    n2 = len(s2)

    prev_row = [0] * (n2 + 1)
    current_row = [0] * (n2 + 1)

    for i in range(n2 + 1):
        prev_row[i] = i * insertion_weight

    for i in range(n1):
        current_row[0] = (i + 1) * deletion_weight
        for j in range(n2):
            deletion_cost = prev_row[j + 1] + deletion_weight
            insertion_cost = current_row[j] + insertion_weight
            substitution_cost = prev_row[j] + substitution_weight * int(s1[i] != s2[j])
            current_row[j + 1] = min(deletion_cost, insertion_cost, substitution_cost)

        prev_row = current_row.copy()

    return prev_row[n2]


def calc_string_similarity(s1, s2):

    n = max(len(s1), len(s2))
    score = calc_levenshtein_distance(s1, s2) / n
    return score


def extract_from_file(file_path):

    testbench_names = set()

    text = open(file_path, encoding="utf8").read()
    for match in re.finditer(r"module\s+(\w+)(?:\s*\([^;]*\))?\s*;", text, re.DOTALL):
        name = match.group(1)
        testbench_names.add(name)

    return testbench_names


def extract_from_dir(dir_path):

    testbench_names = set()

    for file_path in dir_path.glob("tb_*.sv"):
        for name in extract_from_file(file_path):
            testbench_names.add(name)

    return testbench_names


def main():

    parser = argparse.ArgumentParser(description="Run a test bench. Suggests typo corrections.")
    parser.add_argument("tb_module_name", help="Test bench to run")

    args = parser.parse_args()
    target_testbench_name = args.tb_module_name

    self_path = Path(__file__).resolve()
    testbench_dir_path = self_path.parent.parent / "tb"
    testbench_names = extract_from_dir(testbench_dir_path)

    if target_testbench_name not in testbench_names:
        print(f'[ERROR] No test bench module found with name "{target_testbench_name}"')

        suggested_names = set()
        suggested_names.update(
            name
            for name in testbench_names
            if calc_levenshtein_distance(name, target_testbench_name) <= MAX_EDIT_DISTANCE
        )
        suggested_names.update(name for name in testbench_names if name.find(target_testbench_name) != -1)

        if suggested_names:
            suggested_names = list(suggested_names)
            suggested_names.sort(key=lambda x: calc_string_similarity(x, target_testbench_name))

            print()
            print("Did you mean to specify one of these?")
            for name in suggested_names:
                print(f"  {name}")

        exit(1)

    subprocess.check_call([self_path.parent / "run_test", target_testbench_name], cwd=self_path.parent)


if __name__ == "__main__":

    main()

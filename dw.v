module main

import os
import flag
import time

fn file_list(path string) []string {
  files := os.glob(path) or {
    println(err)
    return []
  }

  return files
}

fn munge_path(path string) string {
  expanded := os.expand_tilde_to_home(path)
  dir := os.dir(expanded)
  base := os.base(expanded)
  real := os.real_path(dir)

  return real + os.path_separator + base
}

fn main() {
  mut fp := flag.new_flag_parser(os.args)

  path := fp.string('path', `p`, 'none', 'The path to watch')
  sleep := fp.int('sleep', `s`, 5, 'How many seconds to sleep between passes')

  if path == 'none' {
    println("No path argument given")
    return
  }

  sleep_for := time.second * sleep

  real_path := munge_path(path)

  // List of files the first time we see them
  mut to_be_reported := []string{}

  // List of files that we have displayed
  mut have_been_reported := []string{}

  for {
    // Report the files we saw on the last pass
    for file in to_be_reported {
      println(file)
      have_been_reported << file
    }
    to_be_reported.clear()

    // What files we have seen that have been removed
    for i, file in have_been_reported {
      if !os.exists(file) {
        have_been_reported.delete(i)
      }
    }

    // Get a list of the new files
    files := file_list(real_path)
    for file in files {
      if !have_been_reported.contains(file) {
        to_be_reported << file
      }
    }

    time.sleep(sleep_for)
  }
}

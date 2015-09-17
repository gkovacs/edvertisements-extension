#!/usr/bin/env lsc

# {exec, run} = require 'execSync'
{exec} = require 'shelljs'

fsx = require 'fs-extended'
copy = fsx.copySync
mkdir = fsx.createDirSync
remove = fsx.deleteSync
write = fsx.createFileSync
readJSON = fsx.readJSONSync
writeJSON = fsx.writeJSONSync
exists = fsx.existsSync
mv = fsx.moveSync

version = '1.1'
jsfiles = <[ bower_components abp_filter_parser.js background.js functions.js contentscript.js easylist_text.js  ]>

base_permissions = [
  "http://*/*"
  "https://*/*"
]

base_content_scripts = [
  {
    "matches": [
      "http://*/*"
      "https://*/*"
    ]
    "js": [
      "bower_components/jquery/dist/jquery.min.js"
      "functions.js"
      "baseurl.js"
      "contentscript.js"
    ]
    "run_at": "document_start"
    "all_frames": true
  }
]

buildinfo_list = [
  {
    name: 'Edvertisements Local'
    short_name: 'edvertisementslocal'
    outdir: '.'
    baseurl: 'https://localhost:5001'
    permissions: base_permissions
    content_scripts: base_content_scripts
  }
  {
    name: 'Edvertisements'
    short_name: 'edvertisements'
    baseurl: 'https://edvertisements.herokuapp.com'
    permissions: base_permissions
    content_scripts: base_content_scripts
  }
]

manifest_template = readJSON 'manifest.json'
origdir = process.cwd()

for buildinfo in buildinfo_list
  manifest = {[k,v] for k,v of manifest_template}
  {short_name, baseurl, outdir} = buildinfo
  manifest.version = version
  for k,v of buildinfo
    if <[ baseurl outdir ]>.indexOf(k) != -1
      continue
    manifest[k] = v
  if not outdir?
    outdir = 'build_' + short_name
  outfile = short_name + '-' + version + '.zip'
  if exists outfile
    remove outfile
  if outdir != '.'
    if exists outdir
      remove outdir
    mkdir outdir
    for file in jsfiles
      copy file, outdir + '/' + file, {clobber: true}
  process.chdir outdir
  writeJSON 'manifest.json', manifest, '  '
  write 'baseurl.js', "baseurl = '#{baseurl}';\n"
  exec "zip #{outfile} *js manifest.json"
  mv outfile, origdir + '/' + outfile
  process.chdir origdir

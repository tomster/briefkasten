#!/bin/sh
# Author of this script is Dirk Engling <erdgeist@erdgeist.org>
# It is in the public domain.
#
# process-attachments.sh -d dropdir
#
# This script parses through all the attachments and tries to
# unpack archives it finds on the way.
#
# For all the known files it finds it calls the cleaning function
# it knows about
#
###################################

# some defaults, user configurable

###
# Do not edit anything below this line
###

##
# function declarations
process_single_file () {
  the_file=$1
  the_destination=$2

  # First determine the file type
  the_type=`file -bi "${the_file}"`

  case ${the_type%;*} in
  text/plain)          cp                "${the_file}" "${the_destination}";;
  text/html)           process-html.sh   "${the_file}" "${the_destination}";;
  application/msword)  process-msword.sh "${the_file}" "${the_destination}";;
  application/pdf)     process-pdf.sh    "${the_file}" "${the_destination}";;
  audio/mpeg)          process-mpeg.sh   "${the_file}" "${the_destination}";;
  image/*)             process-image.sh  "${the_file}" "${the_destination}" "${the_type}";;

# archive and compression format
  application/zip)     process_zip.sh    "${the_file}" "${the_destination}";;
  application/x-bzip2) process_bzip.sh   "${the_file}" "${the_destination}";;
  application/x-tar)   process_tar.sh    "${the_file}" "${the_destination}";;

# every unknown format is just copied
# this means that the server tried its best and is at least not worse
# than plain email
  *)                   cp                "${the_file}" "${the_destination}";;

  esac
}

# define our bail out shortcut
exerr () { echo "ERROR: $*" >&2 ; exit 1; }

# this is the usage string in case of error
usage="process-attachments.sh [-d dropdir]"

# parse commands
while getopts :d: arg; do case ${arg} in
  d) the_dropdir="${OPTARG}";;
  ?) exerr $usage;;
esac; done; shift $(( ${OPTIND} - 1 ))

[ -d "${the_dropdir}" ] || exerr "Can't access drop directory"

# If we're passed a config file to parse, source it
[ "${the_config}" -a -r "${the_config}" ] && . "${the_config}"

unset my_dispatcher
if [ "${the_jdispatcher_dir}" ]; then
  my_dispatcher=$( "${the_jdispatcher_dir}"/claim )

  # If we can not allocate a dispatcher here, return an error
  # TODO: report, what went wrong, maybe wait
  [ $? -eq 0 -a "${my_dispatcher}" ] || exit 1

  cleanser_ippport=read < "${my_dispatcher}"/ip
  [ "${cleanser_ippport}" ] || exit 1

  # Setup cleanser ip and port
  the_cleanser=${cleanser_ippport%%:*}
  the_ssh_conf="-p ${cleanser_ippport##*:}"

  # If we were asked to use jdispatch but can not deduct how
  # to connect, return an error
  [ "${the_cleanser}" ] || exit 1
fi

# If we have a remote cleanser host, clean the attachments there
if [ "${the_cleanser}" ]; then
  the_ssh_conf="${the_ssh_conf} -o PasswordAuthentication=no"
  [ "${the_cleanser_ssh_conf}" ] && the_ssh_conf="-F ${the_cleanser_ssh_conf} ${the_ssh_conf}"
  the_remote_dir=`basename "${the_dropdir}"`

  # copy over the attachments
  scp ${the_ssh_conf} -r ${the_dropdir} ${the_cleanser}:${the_remote_dir}
  [ $? -eq 0 ] || exit $?

  # execute remote cleanser job
  ssh ${the_ssh_conf} ${the_cleanser} process-attachments.sh -d ${the_remote_dir}
  the_return_code=$?

  # get back the result (and error code)
  scp ${the_ssh_conf} -r ${the_cleanser}:${the_remote_dir} `dirname ${the_dropdir}`

  # remove remote dir or release jail to jdispatcher
  if [ "${my_dispatcher}" ]; then
    ${my_dispatcher}/release
  else
    ssh ${the_ssh_conf} ${the_cleanser} rm -r ${the_remote_dir}
  fi

  exit ${the_return_code}
fi

# Check for attachment directory.
# If it is not there, we got nothing to do
[ -d "${the_dropdir}"/attach/ ] || exit 0

mkdir "${the_dropdir}/clean"
for the_attachment in ${the_dropdir}/attach/*; do
  [ -f "${the_attachment}" ] && process_single_file "${the_attachment}" ${the_dropdir}/clean
done

# We're done, rest in recursion
exit 0

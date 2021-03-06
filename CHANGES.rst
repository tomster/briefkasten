0.2.17  - Unreleased
--------------------


0.2.16  - 2018-02-12
--------------------

- Reenabled sending of uncleansed attachments via email (if no "dirty archive" has been
  configured) - this had been a regression introduced in the 0.2 branch when adding the archive
  feature

- Fixed editor template when uncleansed attachments were included (if no "dirty archive" has been
  configured) - this had been a regression introduced in the 0.2 branch when adding the archive
  feature

- Make the timeout value how long a submission token is valid configurable (instead of hard coding
  it to 10 minutes)

- Fixed various version pins and test fixtures to enable running tests in the year 2018 :)

- Upgraded OS to 10.3-RELEASE


0.2.15  - 2016-09-01
--------------------

This is the first public release of the 0.2 branch after some extensive development and in-house testing.

- major refactoring (separate web app and worker into separate code running in separate jails)
- use custom FreeBSD package repo with known-good configurations and versions which makes deployment much (much!) more stable
- use ephemeral cleanser jails
- use ephemeral storage for initial fileupload


0.1.10 - Unreleased
-------------------

 * improved watchdog deployment


0.1.9 - 2013-02-23
------------------

 * added a middleware_scripts/test_briefkasten.sh script that does local housekeeping on the server.
   The script takes the webapp directory and the pgp directory (usually ~/.gnupg/) as parameters and tries to access the public key ring. It then checks for missing keys, inaccessible keys, expired keys and keys that expire soon (or never).
   Users with keys that expire soon will receive an email, mentioning the problem. Administrators receive an email with an overview of all the problematic keys.
 * add a standalone 'watchdog' script that ensures that the whole stack is up and running as expected


0.1.8 - 2012-08-30
------------------

 * allow theming of the application via `Diazo <http://docs.diazo.org/en/latest/index.html>`_

 * remove all ZEIT ONLINE specific branding and assets from markup
   This addresses issues `#3 <https://github.com/ZeitOnline/briefkasten/issues/3>`_
   and `#10 <https://github.com/ZeitOnline/briefkasten/issues/10>`_ 
   thanks to @residuum and @Mandalka for raising the issue.

 * added BSD 3-clause license.
   This addresses `issue #8 <https://github.com/ZeitOnline/briefkasten/issues/8>`_

0.1.7 - 2012-08-08
------------------

 * generate the message to the editors via template (instead of hard-coding it in the processing shell script)

0.1.6 - 2012-08-06
------------------

 * Cosmetic tweaks

0.1.5 - 2012-08-06
------------------

 * preserve the file ending of attachments (but still replace the actual name with a random token)

0.1.4 - 2012-08-01
------------------

 * (re-) add sanitizing of office documents

0.1.3.1 - 2012-08-01
--------------------

 * fixed typo

0.1.3 - 2012-07-31
------------------

 * use a `cryptographically suitable random generator <http://docs.python.org/library/os.html#os.urandom>`_
   This addresses `issue #2 <https://github.com/ZeitOnline/briefkasten/issues/2>`_ 
   thanks to @alech (Alexander Klink) for reporting this.

 * use a `constant time comparison algorithm <http://codahale.com/a-lesson-in-timing-attacks/>`_ to avoid
   `timing attacks <https://en.wikipedia.org/wiki/Timing_attack>`_.
   This addresses `issue #4 <https://github.com/ZeitOnline/briefkasten/issues/4>`_
   thanks to @stefanw (Stefan Wehrmeyer) for reporting this.

 * generate random filenames when saving uploaded attachments.
   this is both because their names may contain compromising information but also this could otherwise
   lead to files outside the dropbox container being overwritten.
   Thanks to Alexander Klink (@alech) for pointing out this flaw.

 * Use secure rm instead of rm, if it is available.

0.1.2 - 2012-07-31
------------------

 * further cosmetic layout fixes to the upload form
 * enable submission of up to ten attachments

0.1.1 - 2012-07-31
------------------

 * apply header and footer to the submission form (since it is no longer included via an iframe).

0.1 - 2012-07-30
----------------

Initial public release

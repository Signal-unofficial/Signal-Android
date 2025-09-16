# Signal Android

Signal is a simple, powerful, and secure messenger.

Signal uses your phone's data connection (WiFi/3G/4G/5G) to communicate securely. Millions of people use Signal every day for free and instantaneous communication anywhere in the world. Send and receive high-fidelity messages, participate in HD voice/video calls, and explore a growing set of new features that help you stay connected. Signal’s advanced privacy-preserving technology is always enabled, so you can focus on sharing the moments that matter with the people who matter to you.

Currently available on the Play Store and [signal.org](https://signal.org/android/apk/).

<a href='https://play.google.com/store/apps/details?id=org.thoughtcrime.securesms&pcampaignid=MKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'>
  <img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png' height='80px'/>
</a>

## Contributing Bug reports

We use GitHub for bug tracking. Please search the existing issues for your bug and create a new one if the issue is not yet tracked!

[https://github.com/signalapp/Signal-Android/issues]

## Joining the Beta

Want to live life on the bleeding edge and help out with testing?

You can subscribe to Signal Android Beta releases here:
[https://play.google.com/apps/testing/org.thoughtcrime.securesms]

If you're interested in a life of peace and tranquility, stick with the standard releases.

## Contributing Code

If you're new to the Signal codebase, we recommend going through our issues and picking out a simple bug to fix in order to get yourself familiar. Also please have a look at the [CONTRIBUTING.md](https://github.com/signalapp/Signal-Android/blob/main/CONTRIBUTING.md), that might answer some of your questions.

For larger changes and feature ideas, we ask that you propose it on the [unofficial Community Forum](https://community.signalusers.org) for a high-level discussion with the wider community before implementation.

## Contributing Ideas

Have something you want to say about Signal projects or want to be part of the conversation? Get involved in the [community forum](https://community.signalusers.org).

Help

====

## Support

For troubleshooting and questions, please visit our support center!

[https://support.signal.org/]

## Documentation

Looking for documentation? Check out the wiki!

[https://github.com/signalapp/Signal-Android/wiki]

## Building From Source

- Install Docker Desktop
- Run `docker compose run -d --rm build` to create an `.aab` bundle.
  Note that when building from scratch,
  this operation takes at least an hour and 15GB of memory.
  - If your PC doesn't have at least 15GB of RAM (double recommended,
    since your host needs memory, too), then this cannot be done.
    Instead, you'll need to perform a manual installation. Good luck.
    You will need to install:
    - Git
    - Java 17+
    - Android SDK 12.0+ (or the much larger Android Studio app that includes it)
    The `build` stage of the relevant [Dockerfile](./Dockerfile) contains steps
    for installing these tools on Ubuntu 24.04 (Noble), as well as running the build itself.
    If ever this information is incorrect or outdated, see the Dockerfile instead.
  - If your PC does meet this memory requirement, but Docker doesn't use
    that much memory (defaults to 50% of the maximum host memory), see:
    [raising the Docker memory limit](https://docs.docker.com/desktop/settings-and-maintenance/settings/#advanced).
- When the build completes, run `docker compose run -d --rm package`
  to create unsigned `.apk` files in [`splits`](./app/build/outputs/apks/splits).
  This operation is significantly faster.
- Run `./gen-keystore` to generate the keys necessary for signing the APKs.
  Use a unique, secure password that you'll remember, as you'll
  need it in later steps. Note that in a production setting, this file would
  not be regenerated frequently, but rather reused until its expiry nears.
- Remove the `.example` file extension from all [`secrets`](./reproducible-builds/secrets/)
  and change the contents to make them your own, for security purposes.
- Run `docker compose run -it --rm sign` to sign the APKs through the console.
  Feel free to backup the unsigned APKs in another folder.
- Run `docker compose up -d run` to run an emulator with the APKs installed.
  Docker will expose the emulator on a random port
  (e.g, the `50000` in `50000:8000`), making it accessible in your browser
  (i.e, `localhost:50000`).

## Legal things

### Cryptography Notice

This distribution includes cryptographic software. The country in which you
currently reside may have restrictions on the import, possession, use, and/or
re-export to another country, of encryption software.
BEFORE using any encryption software, please check your country's laws,
regulations and policies concerning the import, possession, or use, and
re-export of encryption software, to see if this is permitted.
See <http://www.wassenaar.org/> for more information.

The U.S. Government Department of Commerce, Bureau of Industry and Security
(BIS), has classified this software as Export Commodity Control Number (ECCN)
5D002.C.1, which includes information security software using or performing
cryptographic functions with asymmetric algorithms.
The form and manner of this distribution makes it eligible for export under
the License Exception ENC Technology Software Unrestricted (TSU) exception
(see the BIS Export Administration Regulations, Section 740.13) for both
object code and source code.

### License

Copyright 2013-2025 Signal Messenger, LLC

Licensed under the GNU AGPLv3: [https://www.gnu.org/licenses/agpl-3.0.html]

Google Play and the Google Play logo are trademarks of Google LLC.

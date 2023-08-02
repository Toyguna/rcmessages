# rcmessages
## A customizable TF2 Sourcemod plugin that sends text messages to the chat.

## Installation

Put the ``randomchatmsg`` folder inside ``addons/sourcemod/configs``
Put the ``.smx`` file to your plugins folder.


## How to use

Add your text messages to the file ``messages.txt`` in the path ``addons/sourcemod/configs/randomchatmsg``; each line represents one message.



## Misc.

- ``rcmsg_prefix`` The prefix of messages.
- ``rcmsg_prefixcolor`` The prefix's text color. (Hex Code without #)
- ``rcmsg_interval`` The interval between chat messages. (In seconds, default = 300.0, min = 5.0)

- ``sm_update_msgs`` Updates the messages in the ``addons/sourcemod/configs/randomchatmsg/messages.txt`` file.
- ``sm_update_msgs`` Updates the interval.

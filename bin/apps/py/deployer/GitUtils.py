from subprocess import check_output
from getpass import getuser

"""
  @package: deployer
   @script: VersionUtils.py
  @purpose: Provides an engine to handle app versions.
  @created: Nov 14, 2019
   @author: <B>H</B>ugo <B>S</B>aporetti <B>J</B>unior
   @mailto: yorevs@hotmail.com
     @site: https://github.com/yorevs/homesetup
  @license: Please refer to <http://unlicense.org/>
"""


# @purpose: TODO Comment it
class Git:

    def __init__(self, command):
        self.command = 'project-dir'

    @staticmethod
    def top_level_dir():
        return check_output(['git', 'rev-parse', '--show-toplevel']).strip()

    @staticmethod
    def current_branch():
        return check_output(['git', 'symbolic-ref', '--short', 'HEAD']).strip()

    @staticmethod
    def user_name():
        return getuser()
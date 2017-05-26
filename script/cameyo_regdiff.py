#   _ __ _   _ ____________
#  | '__| | | |_  /_  /_  /
#  | |  | |_| |/ / / / / /
#  |_|   \__,_/___/___/___|
#

import os, sys

OLD_NAME = 'old.reg'
NEW_NAME = 'new.reg'
DIFF_NAME = 'diff.reg'

def get_script_path():
    return os.path.dirname(os.path.realpath(sys.argv[0]))

argc = len(sys.argv)
if not ((argc == 2) and (os.path.isdir(sys.argv[1]))):
    sys.exit('Usage: %s cameyo_unpacked_dir'
        % (os.path.basename(sys.argv[0])))

dat_to_reg_script = os.path.join(get_script_path(), 'cameyo_dat2reg.py')
root_dir = sys.argv[1]
reg_old = os.path.join(root_dir, 'CHANGES\\VirtReg.Base.dat')
reg_new = os.path.join(root_dir, 'CHANGES\\VirtReg.dat')
os.system('%s %s %s' % (dat_to_reg_script, reg_old, OLD_NAME))
os.system('%s %s %s' % (dat_to_reg_script, reg_new, NEW_NAME))
os.system('regdiff_nouac.exe "%s" "%s" /diff "%s"' % (OLD_NAME, NEW_NAME, DIFF_NAME))


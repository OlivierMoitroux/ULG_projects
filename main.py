"""
You are to develop a  forensics tool, for the FAT32 file system, that recovers
data from the slack space at the end of the last cluster1 making up a file
"""

def getStartFat():
    # TODO
    return 5

def getRootDirStructure(content, startFat):
    """The first sector of cluster 2 (the data region of the disk)"""

    #  contains the count of 32byte directory entries in the root directory
    BPB_RootEntCnt_start = startFat+ fat['BPB_RootEntCnt'][0]
    BPB_RootEntCnt_end = BPB_RootEntCnt_start + fat['BPB_RootEntCnt'][1]
    BPB_RootEntCnt = content[BPB_RootEntCnt_start:BPB_RootEntCnt_end]
    BPB_RootEntCnt = int.from_bytes(BPB_RootEntCnt, byteorder='big')

    BPB_BytsPerSec_start = startFat + fat['BPB_BytsPerSec'][0]
    BPB_BytsPerSec_end = BPB_BytsPerSec_start + fat['BPB_RootEntCnt'][1]
    BPB_BytsPerSec = content[BPB_BytsPerSec_start:BPB_BytsPerSec_end]
    BPB_BytsPerSec = int.from_bytes(BPB_BytsPerSec, byteorder='big')

    BPB_BytsPerSec = SECTOR_SIZE
    RootDirSectors = ((BPB_RootEntCnt * 32) + (BPB_BytsPerSec-1)) / BPB_BytsPerSec
    return RootDirSectors


# -----
# Constants

SECTOR_SIZE = 512
START_PARTITION_BLOCK_NO = getStartFat() # TODO
DISKIMG = 'mock.img'
PRIMARY_PART = 1  # primary partition number of the partition containing the
# file of interest. # TODO
FILE_PATH_INTEREST = "/dir/file.txt"  # TODO
BYTE_SIZE = 8

fat = {"BPB_RootEntCnt":(17, 2), 'BPB_BytsPerSec':(11, 2), 'BPB_RootClu':(
    44, 4)}
# ----

def readFile():
    with open(DISKIMG, 'rb') as f:
        content = f.read()
        return content
if __name__ == '__main__':
    # STEP 1: locate, raed and extract import info from Boot Sector
    # -> First 512 bytes of the disk
    content = readFile()

    # STEP 2: Locate the root directory, get the list of files and folders
    start_data = getRootDirStructure(content, getStartFat())




    # STEP3: Access the file and directories using info from root directory
    # and the FAT32 table

    # Fat table contains all clusters belonging to a particular file.
    # Contains a big array of 32 bit integers


# All files in the disk image are of type 0x20 in the corresponding directory
# entry.



# with open(DISKIMG, 'rb') as f:
#     # blockNo = 1
#     # block = f.read(BLOCK_SIZE * 2**10)
#     byte = f.read(8)
#     byteNo = 0
#     while byte != "" and byteNo != START_PARTITION_BLOCK_NO:
#         # Do stuff with a block
#         #block = f.read(BLOCK_SIZE * 2 ** 10)
#         byte = f.read(8)
#         byteNo += 1





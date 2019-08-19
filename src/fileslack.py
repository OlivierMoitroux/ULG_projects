#!/usr/bin/python3.6

import sys
from argparse import ArgumentParser

BYTES_PER_SECTOR = 512
# PARTIITON TABLE PARSING
NB_SECTOR_BYTES_NB = 4
CHS_ADDRESS_BYTES_NB = 3

def offset_to_address(address, file, current_address):
	offset = round(address - current_address)

	if offset < 0:
		raise Exception("Error: Cannot offset to address (address < current_address).")
	else:
		file.read(offset)
	
	return address
	

def parse_boot_sector(file, current_address):
	file.read(446) # Pass the boostrap code

	current_address = current_address + 446

	partitions_info = list()
	
	partition_info, current_address = parse_partition_table(file, current_address)
	partitions_info.append(partition_info)

	partition_info, current_address = parse_partition_table(file, current_address)
	partitions_info.append(partition_info)

	partition_info, current_address = parse_partition_table(file, current_address)
	partitions_info.append(partition_info)

	partition_info, current_address = parse_partition_table(file, current_address)
	partitions_info.append(partition_info)

	i = 0
	while i < 4:
		partition_type = get_partition_type(partitions_info[i][0])
		print("Partition 1 : " + str(partition_type))

		i = i + 1

	boot_signature = file.read(2)
	current_address = current_address + 2

	if boot_signature != b'U\xaa':
		raise Exception("Error: Unvalid Boot Signature " + str(boot_signature) + ".")

	return partitions_info, current_address

def parse_partition_table(file, current_address):
	global NB_SECTOR_BYTES_NB
	global CHS_ADDRESS_BYTES_NB

	status = file.read(1)
	current_address = current_address + 1

	begin_chs_address = file.read(CHS_ADDRESS_BYTES_NB)
	current_address = current_address + CHS_ADDRESS_BYTES_NB

	partition_type_id = file.read(1)
	current_address = current_address + 1

	end_chs_address = file.read(CHS_ADDRESS_BYTES_NB)
	current_address = current_address + CHS_ADDRESS_BYTES_NB

	first_sector_lba = file.read(4)
	current_address = current_address + 4

	nb_sector = file.read(NB_SECTOR_BYTES_NB)
	current_address = current_address + NB_SECTOR_BYTES_NB

	return (partition_type_id, begin_chs_address, end_chs_address, first_sector_lba, nb_sector), current_address

def get_partition_type(partition_type_byte):
	if partition_type_byte == b'\x0c':
		return 'fat32_lba'

	elif partition_type_byte == b'\x00':
		return 'empty'

	else:
		raise Exception("Error: Unknwown partition type id " + str(partition_type_byte) + ".")

def parse_partition(partition_info, file, current_address):
	global BYTES_PER_SECTOR
	global NB_SECTOR_BYTES

	partition_type_id, begin_chs_address, end_chs_address, first_sector_lba, nb_sector_bytes = partition_info

	nb_sector = int.from_bytes(nb_sector_bytes, byteorder="little")
	
	print("Number of sectors : " + str(nb_sector) + ".")

	first_partition_address = int.from_bytes(first_sector_lba, byteorder="little") * 512

	current_address = offset_to_address(first_partition_address, file, current_address)

	boot_sector_info, current_address = parse_partition_boot_sector(file, current_address)

	BPB_BytsPerSec, BPB_SecPerClus, BPB_RsvdSecCnt, BPB_NumFATs, BPB_RootEntCnt, BPB_TotSec16, BPB_HiddSec, BPB_TotSec32, BPB_RootClus, BPB_FATSz32, BPB_FATSz16 = boot_sector_info

	RootDirSectors = get_root_dir_sector_number(boot_sector_info) # Number of sector in root directory

	DataSecNB = get_data_region_sector_number(boot_sector_info, RootDirSectors)

	CountofClusters = DataSecNB / BPB_SecPerClus

	FATType = 32

	print("Root Directoy is on cluster " + str(BPB_RootClus) + " has " + str(RootDirSectors) + " sectors.")

	root, current_address = parse_root_directory(file, current_address, first_partition_address, boot_sector_info, RootDirSectors, FATType)
	
def parse_root_directory(file, current_address, first_partition_address, boot_sector_info, RootDirSectors, FATType):

	root = dict()

	BPB_BytsPerSec, BPB_SecPerClus, BPB_RsvdSecCnt, BPB_NumFATs, BPB_RootEntCnt, BPB_TotSec16, BPB_HiddSec, BPB_TotSec32, BPB_RootClus, BPB_FATSz32, BPB_FATSz16 = boot_sector_info

	FirstDataSector = get_first_data_sector(boot_sector_info, RootDirSectors) # First Sector of Data region

	FirstRootDataSector = get_first_sector_of_cluster_n(BPB_RootClus, BPB_SecPerClus, FirstDataSector) # First Sector of root directory

	first_root_dir_address = sector_to_address(first_partition_address, FirstRootDataSector)

	current_address = offset_to_address(first_root_dir_address, file, current_address)

	# Normally --> Check if root directory not on several clusters but we will consider that it's always on one.
	ThisFATSecNum, ThisFATEntOffset = getFatSector(boot_sector_info, BPB_RootClus, FATType)

	parse_directory(file, current_address, first_partition_address, boot_sector_info, FirstDataSector, FATType)

	return root, current_address

def parse_directory(file, current_address, first_partition_address, boot_sector_info, FirstDataSector, FATType):

	BPB_BytsPerSec, BPB_SecPerClus, BPB_RsvdSecCnt, BPB_NumFATs, BPB_RootEntCnt, BPB_TotSec16, BPB_HiddSec, BPB_TotSec32, BPB_RootClus, BPB_FATSz32, BPB_FATSz16 = boot_sector_info

	dir_entries = parse_directory_entries(file, current_address, first_partition_address, FATType)

	for dir_name, file_attribute, cluster_nb in dir_entries:
		if fat_entry[11] == b'\x10':
			type = "directory"
		elif fat_entry[11] == b'\x20':
			type = "file"
		else:
			continue
		print("Parsing " + type + " of name " + dir_name + "...")

		FirstDataSector = get_first_sector_of_cluster_n(cluster_nb, BPB_SecPerClus, FirstDataSector)

		current_address = offset_to_address(first_dir_address, file, current_address)

		if type == "directory":
			parse_directory(file, current_address, first_partition_address, boot_sector_info, FirstDataSector, FATType)

		else:
			pass

def parse_directory_entries(file, current_address, first_partition_address, FATType):
	dir_entries = list()

	cluster_nb = None
	
	while not ((FATType == 12 and cluster_nb == b'\xff8') or (FATType == 16 and cluster_nb == b'\xfff8') or (FATType == 32 and cluster_nb == b'\xfff')):
		fat_entry = file.read(32)

		print(fat_entry)

		dir_name = fat_entry[0:10].decode("ascii")

		file_attribute = fat_entry[11]

		cluster_nb = int.from_bytes(fat_entry[20:21] + fat_entry[26:27], byteorder="little")

		dir_entries.append((dir_name, file_attribute, cluster_nb))

		print((dir_name, file_attribute, cluster_nb))

	return dir_entries
	

def sector_to_address(first_partition_address, n_sector):
	return first_partition_address + ((n_sector - 1) * 512)

def get_first_sector_of_cluster_n(N, BPB_SecPerClus, FirstDataSector):
	return ((N - 2) * BPB_SecPerClus) + FirstDataSector

def getFatSector(boot_sector_info, N, FATType):
	BPB_BytsPerSec, BPB_SecPerClus, BPB_RsvdSecCnt, BPB_NumFATs, BPB_RootEntCnt, BPB_TotSec16, BPB_HiddSec, BPB_TotSec32, BPB_RootClus, BPB_FATSz32, BPB_FATSz16 = boot_sector_info

	if(BPB_FATSz16 != 0):
		FATSz = BPB_FATSz16

	else:
		FATSz = BPB_FATSz32
	
	if(FATType == 16):
		FATOffset = N * 2

	elif (FATType == 32):
		FATOffset = N * 4

	ThisFATSecNum = BPB_RsvdSecCnt + (FATOffset/BPB_BytsPerSec)
	ThisFATEntOffset = FATOffset % BPB_BytsPerSec

	return ThisFATSecNum, ThisFATEntOffset

def get_data_region_sector_number(boot_sector_info, RootDirSectors):

	BPB_BytsPerSec, BPB_SecPerClus, BPB_RsvdSecCnt, BPB_NumFATs, BPB_RootEntCnt, BPB_TotSec16, BPB_HiddSec, BPB_TotSec32, BPB_RootClus, BPB_FATSz32, BPB_FATSz16 = boot_sector_info

	if(BPB_FATSz16 != 0):
		FATSz = BPB_FATSz16
	else:
		FATSz = BPB_FATSz32

	if(BPB_TotSec16 != 0):
		TotSec = BPB_TotSec16

	else:
		TotSec = BPB_TotSec32

	DataSecNB = TotSec - (BPB_RsvdSecCnt + (BPB_NumFATs * FATSz) + RootDirSectors);

	return DataSecNB

def get_root_dir_sector_number(boot_sector_info):

	BPB_BytsPerSec, BPB_SecPerClus, BPB_RsvdSecCnt, BPB_NumFATs, BPB_RootEntCnt, BPB_TotSec16, BPB_HiddSec, BPB_TotSec32, BPB_RootClus, BPB_FATSz32, BPB_FATSz16 = boot_sector_info

	RootDirSectors = round((BPB_RootEntCnt * 32) + (BPB_BytsPerSec - 1) / BPB_BytsPerSec)

	return RootDirSectors

def get_first_data_sector(boot_sector_info, RootDirSectors):

	BPB_BytsPerSec, BPB_SecPerClus, BPB_RsvdSecCnt, BPB_NumFATs, BPB_RootEntCnt, BPB_TotSec16, BPB_HiddSec, BPB_TotSec32, BPB_RootClus, BPB_FATSz32, BPB_FATSz16 = boot_sector_info

	if(BPB_FATSz16 != 0):
		raise Exception("Error : Tool does not support FAT16")
	else:
		FATSz = BPB_FATSz32

	FirstDataSector = BPB_RsvdSecCnt + (BPB_NumFATs * FATSz) + RootDirSectors

	return FirstDataSector
	
def parse_partition_boot_sector(file, current_address):
	BS_jmpBoot = file.read(3) # Jump Instruction to boot code
	current_address = current_address + 3

	BS_OEMName = file.read(8) # OEM NAME (ascii)
	current_address = current_address + 8

	BPB_BytsPerSec = file.read(2) # Bytes per sector
	current_address = current_address + 2

	BPB_SecPerClus = file.read(1) # Sector per cluster
	current_address = current_address + 1

	BPB_RsvdSecCnt = file.read(2) # Number of reserved sectors in reserved region
	current_address = current_address + 2

	BPB_NumFATs = file.read(1) # Number of Fat structure
	current_address = current_address + 1

	BPB_RootEntCnt = file.read(2) # Number of 32-byte directory entries in the root directory
	current_address = current_address + 2

	BPB_TotSec16 = file.read(2) # 16-bit total count of sectors in volume
	current_address = current_address + 2

	BPB_Media = file.read(1)
	current_address = current_address + 1

	BPB_FATSz16 = file.read(2)
	current_address = current_address + 2

	BPB_SecPerTrk = file.read(2)
	current_address = current_address + 2

	BPB_NumHeads = file.read(2)
	current_address = current_address + 2

	BPB_HiddSec = file.read(4) # Number of hidden sectors preceding the partition that contains this FAT volume
	current_address = current_address + 4

	BPB_TotSec32 = file.read(4) # 32-bit total count of sectors on the volume
	current_address = current_address + 4

	"""
		ONLY FOR FAT32
	"""

	BPB_FATSz32 = file.read(4)
	current_address = current_address + 4

	BPB_ExtFlags = file.read(2)
	current_address = current_address + 2

	BPB_FSVer = file.read(2)
	current_address = current_address + 2

	BPB_RootClus = file.read(4)
	current_address = current_address + 4

	BPB_FSInfo = file.read(2)
	current_address = current_address + 12

	BPB_Reserved = file.read(12)
	current_address = current_address + 12

	BS_DrvNum = file.read(1)
	current_address = current_address + 1

	BS_Reserved1 = file.read(1)
	current_address = current_address + 1

	BS_BootSig = file.read(1)
	current_address = current_address + 1	

	BS_VolID = file.read(4)
	current_address = current_address + 4		

	BS_VolLab = file.read(11)
	current_address = current_address + 11		

	BS_FilSysType = file.read(8)
	current_address = current_address + 8		
	
	return (int.from_bytes(BPB_BytsPerSec, byteorder="little"), int.from_bytes(BPB_SecPerClus, byteorder="little"), int.from_bytes(BPB_RsvdSecCnt, byteorder="little"), int.from_bytes(BPB_NumFATs, byteorder="little"), int.from_bytes(BPB_RootEntCnt, byteorder="little"), int.from_bytes(BPB_TotSec16, byteorder="little"), int.from_bytes(BPB_HiddSec, byteorder="little"), int.from_bytes(BPB_TotSec32, byteorder="little"), int.from_bytes(BPB_RootClus, byteorder="little"), int.from_bytes(BPB_FATSz32, byteorder="little"), int.from_bytes(BPB_FATSz16, byteorder="little")), current_address
	

def chs_to_lba(chs_address, nb_sectors, nb_heads):
	h = chs_address[0]
	s = chs_address[1] & 0b00111111
	c_8_9 = (chs_address[1] >> 6) << 8
	c = chs_address[2] + c_8_9

	return (c * nb_heads + h) * nb_sectors + s - 1

def main(args):
	disk_image_name = getattr(args, 'if').split("=")[1]

	file = open(disk_image_name, "rb")

	current_address = 0
	partitions_info, current_address = parse_boot_sector(file, current_address)
	
	i = 0
	print("Analyzing partition " + str(i) + ".")
	parse_partition(partitions_info[i], file, current_address)
	
	

	file.close()


if __name__ == '__main__':

	usage = """
	USAGE:      python3 main.py <options>
	EXAMPLES:   (1) python fileslack if=diskimg part=primarypart file
	"""

	parser = ArgumentParser(usage)

	parser.add_argument('if',help="""The name of the disk image file to be 
	analysed""",type=str,default="mock.img")

	parser.add_argument('part',help="""The primary partition number of the 
	partition containing the file of interest (you can ignore extended partitions)
	""", type=str, default="1")

	parser.add_argument('file', help=""" The absolute path within the 
	partition of the file of interest. """, type=str, default="/dir/file.txt")
	args = parser.parse_args()


	if args.file:
		file2find = args.file

	if getattr(args, 'if'):
		# diskimage
		diskimage = getattr(args, 'if').split("=")[1]
		filename = diskimage # compatibility with code of team mates

	if getattr(args, 'part'):
		partitionNo = getattr(args, 'part').split("=")[1]

	main(args)

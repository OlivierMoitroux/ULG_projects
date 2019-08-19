from argparse import ArgumentParser

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
        print(args.file)

    if getattr(args, 'if'):
        # diskimage
        diskimage = getattr(args, 'if').split("=")[1]
        filename = diskimage # compatibility with code of team mates
        print(filename)

    if getattr(args, 'part'):
        partitionNo = getattr(args, 'part').split("=")[1]
        print(partitionNo)

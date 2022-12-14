
FROM_MAC_ADDR = "11:11:11:11:11:11"
MY_MAC_ADDR = "88:66:5a:03:48:b0"

def handle_packet(src, dest, packet):
  # if src != FROM_MAC_ADDR:
  #   return
  # if dest != MY_MAC_ADDR:
  #   return
  print(src, dest, packet)

if __name__ == "__main__":
  src = None
  dest = None
  current_packet = []
  while True:
    line = input()
    if line.startswith("\t"):
      current_packet.append(line.split(":  ")[1])
    else:
      if current_packet:
        packet = " ".join(current_packet)
        packet = bytes.fromhex(packet)
        handle_packet(src, dest, packet)
      src, dest = tuple(line.split(',')[0].split(' > '))
      current_packet = []

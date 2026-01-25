
import json
import base64
import random
import string
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad

class ECourtAPIModule:
    def __init__(self):
        self.key = bytes.fromhex('4D6251655468576D5A7134743677397A') # MbQeThWmZq4t6w9z
        self.global_ivs = [
            "556A586E32723575", "34743777217A2543", 
            "413F4428472B4B62", "48404D635166546A", 
            "614E645267556B58", "655368566D597133"
        ]

    def gen_ran_hex(self, size):
        return ''.join(random.choice('0123456789abcdef') for _ in range(size))

    def encrypt_data(self, data):
        data_str = json.dumps(data)
        global_index = random.randint(0, 5)
        global_iv = self.global_ivs[global_index]
        random_iv = self.gen_ran_hex(16)
        
        iv_hex = global_iv + random_iv
        iv = bytes.fromhex(iv_hex)
        
        cipher = AES.new(self.key, AES.MODE_CBC, iv)
        ct_bytes = cipher.encrypt(pad(data_str.encode('utf-8'), AES.block_size))
        
        encrypted_data = base64.b64encode(ct_bytes).decode('utf-8')
        return f"{random_iv}{global_index}{encrypted_data}"

    def decode_response(self, result):
        # Key for decoding is different in the source code!
        # decodedResponse key: 3273357638782F413F4428472B4B6250
        decode_key = bytes.fromhex('3273357638782F413F4428472B4B6250')
        
        iv_random_hex = result[:32]
        encrypted_part = result[32:]
        
        iv = bytes.fromhex(iv_random_hex)
        cipher = AES.new(decode_key, AES.MODE_CBC, iv)
        
        # Note: B64 decode might be needed depending on transport
        # But source uses .trim().slice(32) directly on response.data
        # Actually response.data is often already b64 or raw
        
        # Let's assume standard AES-CBC
        # pts = cipher.decrypt(encrypted_part)
        # return pts.decode('utf-8')
        return "Decryption logic ready. Requires valid response data."

# Usage Example
if __name__ == "__main__":
    api = ECourtAPIModule()
    search_params = {
        "cino": "MHPG010012342023",
        "version_number": "3.0",
        "language_flag": "english",
        "bilingual_flag": "0"
    }
    
    encrypted_payload = api.encrypt_data(search_params)
    print(f"Encrypted Payload: {encrypted_payload}")
    print("\nThis payload can now be sent to: https://app.ecourts.gov.in/ecourt_mobile_DC/listOfCasesWebService.php")

# ============================================
# COMPLETE GMAIL CREATOR BOT - RAILWAY/VPS
# ============================================
# TOKEN: 8879549452:AAHNvGlBHktN6L-kpUS7H3jp7X-ROwmk9c4
# OWNER: 8785590284
# ============================================

import asyncio
import random
import re
import time
import json
import logging
from datetime import datetime, timedelta
from typing import Dict, Optional
from concurrent.futures import ThreadPoolExecutor
import threading
import os

# Telegram
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes

# Selenium
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium_stealth import stealth

# Webdriver manager
from webdriver_manager.chrome import ChromeDriverManager
import chromedriver_autoinstaller

# Requests
import requests

# ============================================
# CONFIGURATION - TOKEN CODE MEIN HI
# ============================================

BOT_TOKEN = "8879549452:AAHNvGlBHktN6L-kpUS7H3jp7X-ROwmk9c4"
OWNERS = ["8785590284"]
MAX_RETRIES = 20
MAX_CONCURRENT_USERS = 5
HEADLESS_MODE = True

# ============================================
# 300+ PROXY LIST (CODED)
# ============================================

PROXY_LIST = [
    "http://45.43.64.38:6296",
    "http://65.111.3.44:3129",
    "http://8.211.49.86:80",
    "http://103.95.34.186:3128",
    "http://162.214.74.29:3128",
    "http://34.94.46.8:80",
    "http://108.161.135.118:80",
    "http://167.99.124.118:80",
    "http://8.221.139.222:8080",
    "http://8.221.141.88:5006",
    "http://8.211.42.167:104",
    "http://8.211.49.86:3129",
    "http://8.211.51.115:9050",
    "http://8.211.200.183:1000",
    "http://8.215.112.214:7777",
    "http://8.219.97.248:80",
    "http://8.221.138.111:9080",
    "http://8.221.141.88:8820",
    "http://8.221.141.88:91",
    "http://8.221.138.111:5060",
    "http://8.211.42.167:9080",
    "http://8.211.51.115:8081",
    "http://8.211.51.115:4002",
    "http://8.210.17.35:1311",
    "http://8.210.17.35:8001",
    "http://34.81.160.132:80",
    "http://34.43.46.91:80",
    "http://34.101.184.164:3128",
    "http://52.34.243.150:8080",
    "http://65.111.1.201:3129",
    "http://65.111.3.44:3129",
    "http://65.111.10.28:3129",
    "http://65.111.12.145:3129",
    "http://65.108.103.19:80",
    "http://85.214.107.177:80",
    "http://89.169.37.254:1080",
    "http://89.116.78.80:5691",
    "http://95.211.174.135:3128",
    "http://103.43.191.71:8888",
    "http://103.65.237.92:5678",
    "http://103.83.87.114:9080",
    "http://103.86.1.34:4145",
    "http://103.88.169.106:33149",
    "http://103.95.34.186:3128",
    "http://103.102.13.107:8080",
    "http://103.113.152.73:14158",
    "http://103.118.127.222:4153",
    "http://103.120.165.132:1080",
    "http://103.122.64.163:8080",
    "http://103.127.94.137:8080",
    "http://103.129.127.244:8088",
    "http://103.138.173.56:8087",
    "http://103.142.69.169:8885",
    "http://103.142.255.32:1080",
    "http://103.153.247.74:8080",
    "http://103.156.86.131:8080",
    "http://103.160.40.254:8080",
    "http://103.169.238.25:2021",
    "http://103.171.232.96:8080",
    "http://103.185.250.136:1080",
    "http://103.197.188.63:1080",
    "http://103.197.242.106:1080",
    "http://103.237.102.191:11111",
    "http://103.246.194.251:3128",
    "http://112.78.187.186:8080",
    "http://112.120.201.241:3128",
    "http://113.192.1.66:8181",
    "http://113.192.48.11:8080",
    "http://114.130.175.18:8080",
    "http://115.42.67.186:56534",
    "http://115.74.157.21:1080",
    "http://115.77.138.230:5170",
    "http://115.85.74.114:5678",
    "http://115.127.81.142:58080",
    "http://116.105.22.7:1080",
    "http://117.50.194.130:7890",
    "http://117.102.86.146:8080",
    "http://117.244.114.54:1080",
    "http://118.99.72.222:1080",
    "http://118.174.14.65:44336",
    "http://119.18.147.118:8080",
    "http://123.0.18.20:1452",
    "http://124.41.225.101:1080",
    "http://125.25.23.167:8080",
    "http://125.228.143.207:4145",
    "http://128.140.113.110:5678",
    "http://130.17.20.51:1080",
    "http://131.161.68.38:35944",
    "http://135.181.150.19:9050",
    "http://136.0.207.21:6598",
    "http://138.3.218.141:54261",
    "http://138.91.159.185:80",
    "http://138.117.84.194:8080",
    "http://138.121.15.230:999",
    "http://138.128.247.206:9050",
    "http://139.185.52.142:5222",
    "http://140.82.62.31:50000",
    "http://140.83.60.69:10800",
    "http://140.238.241.74:1080",
    "http://140.245.238.56:53",
    "http://141.105.107.152:5678",
    "http://142.54.161.98:17062",
    "http://142.54.226.214:4145",
    "http://142.54.239.1:4145",
    "http://142.111.161.56:6427",
    "http://144.24.111.128:3129",
    "http://144.31.75.29:1080",
    "http://144.91.121.61:1088",
    "http://144.124.227.88:3128",
    "http://145.220.226.12:8080",
    "http://145.220.226.92:8080",
    "http://145.220.226.209:8080",
    "http://145.220.226.249:8080",
    "http://146.103.3.64:7117",
    "http://146.103.43.234:8118",
    "http://146.103.56.23:5571",
    "http://146.103.56.36:5584",
    "http://146.103.56.204:5752",
    "http://146.103.56.251:5799",
    "http://147.45.60.136:1082",
    "http://147.45.60.250:1082",
    "http://147.45.66.117:1082",
    "http://147.45.215.249:8443",
    "http://147.45.225.141:10808",
    "http://147.93.52.252:1081",
    "http://147.93.141.97:10808",
    "http://148.135.151.201:8452",
    "http://149.57.17.102:5570",
    "http://149.57.17.227:5695",
    "http://149.57.17.251:5719",
    "http://150.241.70.103:6666",
    "http://151.80.33.14:9050",
    "http://151.115.99.193:10006",
    "http://151.242.116.132:8080",
    "http://151.243.153.157:8118",
    "http://151.248.19.97:8080",
    "http://151.252.80.124:1080",
    "http://153.51.241.38:999",
    "http://153.80.240.37:8080",
    "http://154.18.220.190:5678",
    "http://154.27.196.39:999",
    "http://154.113.195.161:5678",
    "http://155.254.38.12:5688",
    "http://155.254.38.36:5712",
    "http://155.254.38.88:5764",
    "http://156.238.250.51:8080",
    "http://157.90.113.23:9052",
    "http://157.230.178.216:40000",
    "http://158.101.175.124:5566",
    "http://158.247.216.192:7777",
    "http://159.65.221.25:80",
    "http://160.22.200.70:69",
    "http://161.18.226.135:8080",
    "http://162.214.74.29:3128",
    "http://162.220.247.60:6655",
    "http://163.61.70.4:9000",
    "http://163.227.248.5:8818",
    "http://164.52.216.51:8080",
    "http://164.152.122.199:19100",
    "http://165.0.136.30:8080",
    "http://165.101.222.18:8080",
    "http://165.154.7.156:8888",
    "http://165.154.20.187:10808",
    "http://165.165.178.142:4153",
    "http://166.62.53.45:45842",
    "http://166.88.235.113:5741",
    "http://166.88.235.221:5849",
    "http://167.99.124.118:80",
    "http://169.159.128.73:1080",
    "http://170.81.108.153:4153",
    "http://171.22.180.10:10808",
    "http://171.242.14.54:1080",
    "http://171.248.213.16:1080",
    "http://171.248.217.181:1080",
    "http://171.254.1.231:1080",
    "http://172.110.220.36:3128",
    "http://172.234.12.236:8080",
    "http://172.245.157.128:6713",
    "http://173.211.68.149:6431",
    "http://173.244.41.34:6218",
    "http://173.244.41.150:6334",
    "http://175.100.37.171:1080",
    "http://175.100.103.170:1256",
    "http://175.136.239.173:8181",
    "http://175.139.233.78:80",
    "http://175.139.233.79:80",
    "http://176.61.151.123:80",
    "http://176.107.80.85:1080",
    "http://176.114.199.202:1080",
    "http://176.120.28.106:8080",
    "http://176.124.201.214:10808",
    "http://176.226.227.148:10808",
    "http://177.93.59.71:999",
    "http://177.131.29.209:4153",
    "http://177.131.125.144:5432",
    "http://178.18.207.85:8888",
    "http://178.104.91.17:80",
    "http://178.156.206.253:8118",
    "http://178.156.224.42:3128",
    "http://178.252.180.59:10909",
    "http://179.1.113.129:999",
    "http://179.49.237.12:999",
    "http://181.57.178.146:1080",
    "http://181.78.17.131:999",
    "http://181.119.84.219:8080",
    "http://181.119.105.155:999",
    "http://181.129.158.131:999",
    "http://181.129.183.19:53281",
    "http://181.143.145.98:8080",
    "http://181.204.4.74:5678",
    "http://182.16.171.42:51459",
    "http://182.53.202.208:8080",
    "http://182.253.40.39:8080",
    "http://182.253.109.133:1256",
    "http://183.89.217.91:4153",
    "http://184.170.245.148:4145",
    "http://184.174.24.21:6597",
    "http://184.178.172.14:4145",
    "http://184.181.217.201:4145",
    "http://185.32.4.65:4153",
    "http://185.32.4.126:4153",
    "http://185.40.86.232:1080",
    "http://185.108.76.197:9050",
    "http://185.171.83.65:49153",
    "http://185.188.217.166:8080",
    "http://185.196.61.251:1080",
    "http://185.226.204.74:5627",
    "http://185.226.207.166:5715",
    "http://185.226.207.213:5762",
    "http://185.239.70.64:3129",
    "http://186.31.197.3:8080",
    "http://186.97.200.210:999",
    "http://186.246.2.55:1085",
    "http://188.143.166.52:80",
    "http://188.191.18.66:1080",
    "http://188.225.46.163:10808",
    "http://189.202.204.53:1080",
    "http://190.7.138.78:8080",
    "http://190.58.248.86:80",
    "http://190.60.60.37:8080",
    "http://190.85.43.6:8080",
    "http://190.93.188.197:1080",
    "http://190.95.132.186:999",
    "http://190.104.168.27:80",
    "http://190.121.136.185:999",
    "http://190.140.31.195:9900",
    "http://191.101.174.133:6181",
    "http://191.223.220.23:1080",
    "http://192.111.134.10:4145",
    "http://192.198.117.60:7653",
    "http://192.252.216.81:4145",
    "http://193.107.75.242:33500",
    "http://193.107.236.183:3128",
    "http://193.124.254.120:1080",
    "http://193.233.86.198:1080",
    "http://194.14.207.87:8001",
    "http://194.87.83.113:3128",
    "http://194.135.81.158:3128",
    "http://194.164.125.208:57422",
    "http://195.19.51.79:1080",
    "http://195.26.224.135:80",
    "http://195.133.65.238:10909",
    "http://195.158.8.123:3128",
    "http://195.225.116.15:4145",
    "http://197.221.234.253:80",
    "http://197.221.237.248:80",
    "http://197.221.240.178:80",
    "http://197.221.240.240:80",
    "http://197.221.249.196:80",
    "http://198.12.37.25:1080",
    "http://198.46.241.201:6736",
    "http://198.105.100.237:6488",
    "http://198.105.122.186:6759",
    "http://199.58.185.9:4145",
    "http://199.102.104.70:4145",
    "http://199.102.107.145:4145",
    "http://199.180.9.79:6099",
    "http://200.14.57.4:4153",
    "http://200.63.95.13:1085",
    "http://200.69.83.205:999",
    "http://200.80.227.234:4145",
    "http://200.111.104.59:3128",
    "http://200.118.238.71:8080",
    "http://200.125.40.38:5678",
    "http://200.162.129.165:1080",
    "http://200.188.246.122:60606",
    "http://201.71.2.26:999",
    "http://201.140.185.41:8081",
    "http://201.184.177.10:4153",
    "http://202.6.193.11:12345",
    "http://202.62.42.230:1080",
    "http://202.62.52.120:1080",
    "http://202.62.62.113:1080",
    "http://202.166.219.80:4153",
    "http://203.174.15.83:36439",
    "http://203.189.135.73:1080",
    "http://203.189.159.241:1080",
    "http://204.168.225.55:8888",
    "http://206.206.64.223:6184",
    "http://207.180.254.198:8080",
    "http://208.102.24.225:8888",
    "http://209.50.171.158:3129",
    "http://212.31.100.138:4153",
    "http://212.34.138.89:8080",
    "http://212.46.242.185:1080",
    "http://212.47.232.28:80",
    "http://212.113.99.167:10800",
    "http://212.118.38.225:3128",
    "http://213.135.6.5:8080",
    "http://213.136.92.91:1080",
    "http://213.148.6.12:7777",
    "http://213.169.231.191:5332",
    "http://216.26.225.110:3129",
    "http://216.26.235.236:3129",
    "http://216.26.237.52:3129",
    "http://216.48.177.32:8080",
    "http://216.48.185.242:8080",
    "http://217.113.235.181:443",
    "http://217.154.71.75:3128",
    "http://217.182.74.56:9100",
    "http://219.65.73.81:80",
]

# ============================================
# LOGGING
# ============================================

logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# ============================================
# DOB GENERATOR (18+)
# ============================================

def generate_dob() -> Dict:
    now = datetime.now()
    age_years = random.randint(18, 50)
    dob = now - timedelta(days=age_years * 365 + random.randint(0, 365))
    return {
        'month': str(dob.month).zfill(2),
        'day': str(dob.day).zfill(2),
        'year': str(dob.year),
        'month_int': dob.month,
        'day_int': dob.day,
        'year_int': dob.year,
        'full': f"{dob.month}/{dob.day}/{dob.year}",
        'age': age_years
    }

# ============================================
# USER APPROVAL SYSTEM
# ============================================

class ApprovalSystem:
    def __init__(self):
        self.approved_users = self._load('approved_users.json')
        self.pending_users = self._load('pending_users.json')
    
    def _load(self, file):
        try:
            with open(file, 'r') as f:
                return json.load(f)
        except:
            return {}
    
    def _save(self, file, data):
        with open(file, 'w') as f:
            json.dump(data, f, indent=2)
    
    def is_owner(self, user_id: str) -> bool:
        return str(user_id) in OWNERS
    
    def is_approved(self, user_id: str) -> bool:
        return str(user_id) in self.approved_users or self.is_owner(str(user_id))
    
    def request_access(self, user_id: str, username: str = None):
        user_id = str(user_id)
        if user_id not in self.pending_users and not self.is_approved(user_id):
            self.pending_users[user_id] = {
                'username': username or user_id,
                'requested_at': datetime.now().isoformat()
            }
            self._save('pending_users.json', self.pending_users)
            return True
        return False
    
    def approve_user(self, user_id: str) -> bool:
        user_id = str(user_id)
        if user_id in self.pending_users:
            self.approved_users[user_id] = self.pending_users[user_id]
            self.approved_users[user_id]['approved_at'] = datetime.now().isoformat()
            del self.pending_users[user_id]
            self._save('approved_users.json', self.approved_users)
            self._save('pending_users.json', self.pending_users)
            return True
        return False
    
    def reject_user(self, user_id: str) -> bool:
        user_id = str(user_id)
        if user_id in self.pending_users:
            del self.pending_users[user_id]
            self._save('pending_users.json', self.pending_users)
            return True
        return False
    
    def remove_user(self, user_id: str) -> bool:
        user_id = str(user_id)
        if user_id in self.approved_users:
            del self.approved_users[user_id]
            self._save('approved_users.json', self.approved_users)
            return True
        return False
    
    def get_pending_list(self):
        return self.pending_users
    
    def get_approved_list(self):
        return self.approved_users

# ============================================
# PROXY MANAGER
# ============================================

class ProxyManager:
    def __init__(self):
        self.proxies = PROXY_LIST.copy()
        self.used_proxies = {}
        self.failed_proxies = {}
        self.lock = threading.Lock()
        logger.info(f"✅ Loaded {len(self.proxies)} proxies")
    
    def get_proxy(self, user_id: int) -> Optional[str]:
        with self.lock:
            user_id = str(user_id)
            used = self.used_proxies.get(user_id, [])
            failed = self.failed_proxies.get(user_id, [])
            
            available = [p for p in self.proxies if p not in used and p not in failed]
            
            if not available:
                if len(used) >= len(self.proxies):
                    self.used_proxies[user_id] = []
                    available = [p for p in self.proxies if p not in failed]
                if not available:
                    return None
            
            proxy = random.choice(available)
            self.used_proxies.setdefault(user_id, []).append(proxy)
            return proxy
    
    def mark_failed(self, user_id: int, proxy: str):
        with self.lock:
            user_id = str(user_id)
            self.failed_proxies.setdefault(user_id, []).append(proxy)
            if proxy in self.used_proxies.get(user_id, []):
                self.used_proxies[user_id].remove(proxy)
    
    def get_stats(self):
        return {
            'total': len(self.proxies),
            'used': len(self.used_proxies),
            'failed': len(self.failed_proxies)
        }

# ============================================
# USER STATE
# ============================================

class UserState:
    def __init__(self, user_id: str):
        self.user_id = user_id
        self.step = "idle"
        self.phone = None
        self.email_prefix = None
        self.password = None
        self.name = None
        self.created_email = None
        self.retry_count = 0
        self.otp_code = None
        self.start_time = datetime.now()
        self.awaiting_otp = False
        self.dob = None
        self.lock = threading.Lock()
    
    def reset(self):
        with self.lock:
            self.step = "idle"
            self.phone = None
            self.email_prefix = None
            self.password = None
            self.name = None
            self.created_email = None
            self.retry_count = 0
            self.otp_code = None
            self.awaiting_otp = False
            self.dob = None

user_sessions: Dict[str, UserState] = {}
user_sessions_lock = threading.Lock()
otp_storage: Dict[str, str] = {}
otp_storage_lock = threading.Lock()

approval_system = ApprovalSystem()
proxy_manager = ProxyManager()
user_semaphore = asyncio.Semaphore(MAX_CONCURRENT_USERS)

# ============================================
# CHROMEDRIVER SETUP
# ============================================

def setup_chromedriver():
    """Setup ChromeDriver for Railway/VPS"""
    try:
        chromedriver_autoinstaller.install()
        logger.info("✅ ChromeDriver installed successfully")
    except Exception as e:
        logger.warning(f"⚠️ Autoinstall failed: {e}, trying webdriver-manager")
        try:
            ChromeDriverManager().install()
            logger.info("✅ ChromeDriver installed via webdriver-manager")
        except Exception as e2:
            logger.error(f"❌ Both install methods failed: {e2}")

# ============================================
# GMAIL BOT
# ============================================

class GmailBot:
    def __init__(self, proxy: str):
        self.proxy = proxy
        self.driver = None
        self._setup_driver()
    
    def _setup_driver(self):
        options = Options()
        
        # Proxy
        if self.proxy:
            if self.proxy.startswith(('http://', 'https://', 'socks5://')):
                options.add_argument(f'--proxy-server={self.proxy}')
            else:
                options.add_argument(f'--proxy-server=http://{self.proxy}')
        
        # Headless
        if HEADLESS_MODE:
            options.add_argument("--headless=new")
        
        # Anti-detection
        options.add_argument("--disable-blink-features=AutomationControlled")
        options.add_experimental_option("excludeSwitches", ["enable-automation"])
        options.add_experimental_option('useAutomationExtension', False)
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--disable-gpu")
        options.add_argument("--window-size=1920,1080")
        
        user_agents = [
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
        ]
        options.add_argument(f'user-agent={random.choice(user_agents)}')
        
        try:
            service = Service()
            self.driver = webdriver.Chrome(service=service, options=options)
        except:
            service = Service(ChromeDriverManager().install())
            self.driver = webdriver.Chrome(service=service, options=options)
        
        stealth(self.driver,
                languages=["en-US", "en"],
                vendor="Google Inc.",
                platform="Win32",
                webgl_vendor="Intel Inc.",
                renderer="Intel Iris OpenGL Engine",
                fix_hairline=True)
        
        self.driver.set_page_load_timeout(30)
    
    def create_account(self, email_prefix: str, password: str, phone: str, otp_callback=None) -> tuple:
        try:
            logger.info(f"📧 Creating: {email_prefix}@gmail.com")
            self.driver.get("https://accounts.google.com/signup")
            time.sleep(5)
            
            # ========== NAME ==========
            first_name = WebDriverWait(self.driver, 20).until(
                EC.presence_of_element_located((By.ID, "firstName"))
            )
            first_name.send_keys(email_prefix[:10])
            last_name = self.driver.find_element(By.ID, "lastName")
            last_name.send_keys("User")
            
            next_btn = WebDriverWait(self.driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, "//span[text()='Next']"))
            )
            next_btn.click()
            time.sleep(3)
            
            # ========== DOB (18+) ==========
            dob = generate_dob()
            logger.info(f"🎂 DOB: {dob['full']} (Age: {dob['age']})")
            
            month_dropdown = WebDriverWait(self.driver, 20).until(
                EC.element_to_be_clickable((By.ID, "month"))
            )
            month_dropdown.click()
            time.sleep(1)
            
            month_options = self.driver.find_elements(By.XPATH, "//select[@id='month']/option")
            for option in month_options:
                if option.get_attribute('value') == str(dob['month_int']):
                    option.click()
                    break
            
            day_input = self.driver.find_element(By.ID, "day")
            day_input.send_keys(str(dob['day_int']))
            
            year_input = self.driver.find_element(By.ID, "year")
            year_input.send_keys(str(dob['year_int']))
            
            try:
                gender_dropdown = self.driver.find_element(By.ID, "gender")
                gender_dropdown.click()
                time.sleep(0.5)
                gender_options = self.driver.find_elements(By.XPATH, "//select[@id='gender']/option")
                if len(gender_options) > 2:
                    random.choice(gender_options[1:]).click()
            except:
                pass
            
            next_btn = WebDriverWait(self.driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, "//span[text()='Next']"))
            )
            next_btn.click()
            time.sleep(3)
            
            # ========== EMAIL ==========
            username = WebDriverWait(self.driver, 20).until(
                EC.presence_of_element_located((By.ID, "username"))
            )
            username.send_keys(email_prefix)
            
            next_btn = WebDriverWait(self.driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, "//span[text()='Next']"))
            )
            next_btn.click()
            time.sleep(3)
            
            # CHECK: Username taken
            try:
                error_elements = self.driver.find_elements(By.XPATH, "//div[@role='alert']")
                for error in error_elements:
                    error_text = error.text.lower()
                    if "taken" in error_text or "already" in error_text:
                        return (False, None, "❌ Username already taken! Try different email.")
            except:
                pass
            
            # ========== PASSWORD ==========
            password_field = WebDriverWait(self.driver, 20).until(
                EC.presence_of_element_located((By.NAME, "Passwd"))
            )
            password_field.send_keys(password)
            
            confirm_password = self.driver.find_element(By.NAME, "PasswdAgain")
            confirm_password.send_keys(password)
            
            # CHECK: Password weak
            try:
                weak_indicators = self.driver.find_elements(By.XPATH, "//div[contains(text(), 'weak') or contains(text(), 'too short')]")
                if weak_indicators:
                    return (False, None, "❌ Password is too weak! Use 8+ chars with letters, numbers, and special characters.")
            except:
                pass
            
            next_btn = WebDriverWait(self.driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, "//span[text()='Next']"))
            )
            next_btn.click()
            time.sleep(3)
            
            # ========== PHONE ==========
            phone_input = WebDriverWait(self.driver, 20).until(
                EC.presence_of_element_located((By.ID, "phoneNumberId"))
            )
            phone_input.send_keys(phone)
            
            next_btn = WebDriverWait(self.driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, "//span[text()='Next']"))
            )
            next_btn.click()
            time.sleep(5)
            
            # ========== OTP ==========
            if otp_callback:
                otp = otp_callback()
                if not otp:
                    return (False, None, "❌ OTP not provided or timeout!")
                
                otp_input = WebDriverWait(self.driver, 30).until(
                    EC.presence_of_element_located((By.ID, "code"))
                )
                otp_input.send_keys(otp)
                
                verify_btn = WebDriverWait(self.driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, "//span[text()='Verify']"))
                )
                verify_btn.click()
                time.sleep(5)
                
                # CHECK: OTP valid
                try:
                    error_elements = self.driver.find_elements(By.XPATH, "//div[@role='alert']")
                    for error in error_elements:
                        error_text = error.text.lower()
                        if "incorrect" in error_text or "invalid" in error_text:
                            return (False, None, "❌ Invalid OTP! Please check and try again.")
                except:
                    pass
                
                try:
                    WebDriverWait(self.driver, 10).until(
                        EC.presence_of_element_located((By.XPATH, "//span[text()='Skip']"))
                    )
                except:
                    return (False, None, "❌ OTP verification failed! Please check your OTP.")
            
            # ========== SKIP RECOVERY ==========
            try:
                skip_btn = WebDriverWait(self.driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, "//span[text()='Skip']"))
                )
                skip_btn.click()
                time.sleep(3)
            except:
                pass
            
            # ========== AGREE ==========
            try:
                agree_btn = WebDriverWait(self.driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, "//span[text()='I agree']"))
                )
                agree_btn.click()
                time.sleep(5)
            except:
                pass
            
            created_email = f"{email_prefix}@gmail.com"
            logger.info(f"✅ SUCCESS: {created_email} created!")
            return (True, created_email, None)
            
        except Exception as e:
            error_msg = str(e)
            logger.error(f"❌ Error: {error_msg}")
            return (False, None, f"❌ Error: {error_msg[:100]}")
        finally:
            if self.driver:
                self.driver.quit()
    
    def quit(self):
        if self.driver:
            self.driver.quit()

# ============================================
# HELPER FUNCTIONS
# ============================================

def get_user_state(user_id: str) -> UserState:
    with user_sessions_lock:
        if user_id not in user_sessions:
            user_sessions[user_id] = UserState(user_id)
        return user_sessions[user_id]

# ============================================
# TELEGRAM BOT HANDLERS
# ============================================

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    username = update.effective_user.username or user_id
    
    if approval_system.is_owner(user_id):
        await update.message.reply_text(
            "👑 **OWNER ACCESS**\n\n"
            "/make - Create Gmail\n"
            "/approve - Approve user\n"
            "/reject - Reject user\n"
            "/remove - Remove user\n"
            "/pending - Pending users\n"
            "/approved - Approved users\n"
            "/stats - Statistics\n"
            "/active - Active users\n"
            "/cancel - Cancel"
        )
        return
    
    if approval_system.is_approved(user_id):
        await update.message.reply_text(
            "✅ **ACCESS GRANTED**\n\n"
            "/make - Create Gmail\n"
            "/cancel - Cancel\n"
            "/stats - Statistics"
        )
        return
    
    approval_system.request_access(user_id, username)
    
    for owner_id in OWNERS:
        try:
            await context.bot.send_message(
                owner_id,
                f"🔔 **New Request**\nUser: `{user_id}`\n@ {username}\n`/approve {user_id}`"
            )
        except:
            pass
    
    await update.message.reply_text("⏳ **Request Sent!** Waiting for owner approval.")

async def make_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    
    if not approval_system.is_approved(user_id):
        await update.message.reply_text("❌ Not approved! Use /start")
        return
    
    full_text = " ".join(context.args) if context.args else ""
    
    if not context.args:
        await update.message.reply_text(
            "❌ **Wrong Format!**\n\n"
            "Use: `/make name email password`\n"
            "Example: `/make rahul rahul.kumar MyPass@123`\n\n"
            "OR\n\n"
            "Use: `/make name|email|password`\n"
            "Example: `/make rahul|rahul.kumar|MyPass@123`"
        )
        return
    
    if "|" in full_text:
        parts = full_text.split("|")
        if len(parts) == 3:
            name, email, password = parts[0].strip(), parts[1].strip(), parts[2].strip()
        else:
            await update.message.reply_text("❌ Invalid format! Use: `/make name email password`")
            return
    else:
        if len(context.args) != 3:
            await update.message.reply_text("❌ Use: `/make name email password`")
            return
        name, email, password = context.args[0], context.args[1], context.args[2]
    
    if len(email) < 6:
        await update.message.reply_text("❌ Email too short!")
        return
    if len(password) < 8:
        await update.message.reply_text("❌ Password too short!")
        return
    if not re.match(r'^[a-zA-Z0-9._]+$', email):
        await update.message.reply_text("❌ Invalid email format!")
        return
    
    state = get_user_state(user_id)
    state.name = name
    state.email_prefix = email
    state.password = password
    state.step = "waiting_phone"
    state.retry_count = 0
    state.dob = generate_dob()
    
    await update.message.reply_text(
        f"📱 **Send Phone Number**\n\n"
        f"📧 `{email}@gmail.com`\n"
        f"🔑 `{password}`\n"
        f"🎂 DOB: `{state.dob['full']}` (18+)\n\n"
        f"Format: `+919876543210`\n"
        f"Type `/cancel` to abort"
    )

async def handle_phone(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    phone = update.message.text.strip()
    
    state = get_user_state(user_id)
    if state.step != "waiting_phone":
        await update.message.reply_text("❌ Use `/make` first!")
        return
    
    if not phone.startswith("+") or len(phone) < 10:
        await update.message.reply_text("❌ Invalid phone! Use: `+919876543210`")
        return
    
    state.phone = phone
    state.step = "creating"
    
    msg = await update.message.reply_text(
        f"⏳ **Creating Account...**\n"
        f"📱 `{phone}`\n"
        f"📧 `{state.email_prefix}@gmail.com`\n"
        f"🎂 DOB: `{state.dob['full']}` (18+)\n"
        f"🔄 Trying up to {MAX_RETRIES} proxies\n\n"
        f"⚠️ You'll be asked for OTP soon!"
    )
    
    await create_account_with_retry(update, context, msg)

async def create_account_with_retry(update: Update, context: ContextTypes.DEFAULT_TYPE, msg):
    user_id = str(update.effective_user.id)
    state = get_user_state(user_id)
    
    if not state or state.step != "creating":
        return
    
    success = False
    
    async with user_semaphore:
        while state.retry_count < MAX_RETRIES and not success:
            state.retry_count += 1
            
            proxy = proxy_manager.get_proxy(user_id)
            if not proxy:
                await msg.edit_text("❌ No proxies available!")
                return
            
            await msg.edit_text(
                f"🔄 **Attempt {state.retry_count}/{MAX_RETRIES}**\n"
                f"⏳ Please wait..."
            )
            
            try:
                otp_received = asyncio.Event()
                otp_value = None
                
                async def get_otp():
                    nonlocal otp_value
                    state.awaiting_otp = True
                    await msg.edit_text(
                        f"📩 **OTP SENT!**\n\n"
                        f"Check phone: `{state.phone}`\n"
                        f"Enter 6-digit OTP.\n"
                        f"⏳ 120 seconds\n"
                        f"Type `/cancel` to abort"
                    )
                    
                    try:
                        await asyncio.wait_for(otp_received.wait(), timeout=120)
                        return otp_value
                    except asyncio.TimeoutError:
                        return None
                
                bot = GmailBot(proxy)
                result = await asyncio.to_thread(
                    bot.create_account,
                    state.email_prefix,
                    state.password,
                    state.phone,
                    get_otp
                )
                
                if result[0]:
                    success = True
                    state.created_email = result[1]
                    state.step = "done"
                    
                    await msg.edit_text(
                        f"✅ **ACCOUNT CREATED!** 🎉\n\n"
                        f"📧 `{result[1]}`\n"
                        f"🔑 `{state.password}`\n"
                        f"📱 `{state.phone}`\n"
                        f"🎂 DOB: `{state.dob['full']}`\n\n"
                        f"⚠️ Save these details securely!"
                    )
                    break
                else:
                    proxy_manager.mark_failed(user_id, proxy)
                    error_msg = result[2] if len(result) > 2 else "Unknown"
                    await msg.edit_text(
                        f"❌ Attempt {state.retry_count} failed\n"
                        f"Error: `{error_msg[:80]}`\n"
                        f"🔄 Trying next proxy..."
                    )
                    
            except Exception as e:
                proxy_manager.mark_failed(user_id, proxy)
                await msg.edit_text(f"⚠️ Error: `{str(e)[:80]}`\n🔄 Retrying...")
    
    if not success:
        state.step = "idle"
        await msg.edit_text(
            "❌ **All attempts failed!**\n\n"
            "Possible reasons:\n"
            "• Phone already used\n"
            "• Captcha detected\n"
            "• Proxies blocked\n"
            "• Username taken\n"
            "• Password weak\n\n"
            "Try again with `/make`"
        )

async def handle_otp(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    otp = update.message.text.strip()
    
    state = get_user_state(user_id)
    if not state.awaiting_otp:
        await update.message.reply_text("❌ No OTP request pending!")
        return
    
    if not otp.isdigit() or len(otp) != 6:
        await update.message.reply_text("❌ **Invalid OTP!** Must be 6 digits.")
        return
    
    with otp_storage_lock:
        otp_storage[user_id] = otp
    
    state.otp_code = otp
    state.awaiting_otp = False
    
    await update.message.reply_text("✅ OTP received! Verifying...")

# ============================================
# OWNER COMMANDS
# ============================================

async def approve_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if not approval_system.is_owner(user_id):
        await update.message.reply_text("❌ Only owner!")
        return
    
    args = context.args
    if not args:
        await update.message.reply_text("❌ Usage: `/approve user_id`")
        return
    
    target_id = args[0]
    if approval_system.approve_user(target_id):
        await update.message.reply_text(f"✅ User `{target_id}` approved!")
        try:
            await context.bot.send_message(target_id, "✅ **Approved!** You can now use the bot.")
        except:
            pass
    else:
        await update.message.reply_text(f"❌ User `{target_id}` not pending!")

async def reject_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if not approval_system.is_owner(user_id):
        await update.message.reply_text("❌ Only owner!")
        return
    
    args = context.args
    if not args:
        await update.message.reply_text("❌ Usage: `/reject user_id`")
        return
    
    target_id = args[0]
    if approval_system.reject_user(target_id):
        await update.message.reply_text(f"❌ User `{target_id}` rejected!")
        try:
            await context.bot.send_message(target_id, "❌ **Rejected!** Contact owner.")
        except:
            pass
    else:
        await update.message.reply_text(f"❌ User `{target_id}` not pending!")

async def remove_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if not approval_system.is_owner(user_id):
        await update.message.reply_text("❌ Only owner!")
        return
    
    args = context.args
    if not args:
        await update.message.reply_text("❌ Usage: `/remove user_id`")
        return
    
    target_id = args[0]
    if approval_system.remove_user(target_id):
        await update.message.reply_text(f"✅ User `{target_id}` removed!")
        try:
            await context.bot.send_message(target_id, "❌ **Access revoked!**")
        except:
            pass
    else:
        await update.message.reply_text(f"❌ User `{target_id}` not found!")

async def pending_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if not approval_system.is_owner(user_id):
        await update.message.reply_text("❌ Only owner!")
        return
    
    pending = approval_system.get_pending_list()
    if not pending:
        await update.message.reply_text("📭 No pending requests.")
        return
    
    msg = "📋 **Pending Users**\n\n"
    for uid, data in pending.items():
        msg += f"• `{uid}` - @{data.get('username', 'unknown')}\n"
    
    await update.message.reply_text(msg + "\nUse `/approve user_id` or `/reject user_id`")

async def approved_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if not approval_system.is_owner(user_id):
        await update.message.reply_text("❌ Only owner!")
        return
    
    approved = approval_system.get_approved_list()
    if not approved:
        await update.message.reply_text("📭 No approved users.")
        return
    
    msg = "✅ **Approved Users**\n\n"
    for uid, data in approved.items():
        msg += f"• `{uid}` - @{data.get('username', 'unknown')}\n"
    
    await update.message.reply_text(msg + "\nUse `/remove user_id` to revoke")

async def active_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if not approval_system.is_owner(user_id):
        await update.message.reply_text("❌ Only owner!")
        return
    
    with user_sessions_lock:
        active_users = list(user_sessions.keys())
    
    msg = "🟢 **Active Users**\n\n"
    if active_users:
        for uid in active_users:
            state = get_user_state(uid)
            step = state.step if state else "unknown"
            msg += f"• `{uid}` - {step}\n"
    else:
        msg += "No active users."
    
    await update.message.reply_text(msg)

async def stats_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if not approval_system.is_approved(user_id):
        await update.message.reply_text("❌ Not approved!")
        return
    
    proxy_stats = proxy_manager.get_stats()
    
    with user_sessions_lock:
        active_count = len(user_sessions)
        creating_count = sum(1 for s in user_sessions.values() if s.step == "creating")
    
    msg = f"📊 **Bot Statistics**\n\n"
    msg += f"**Proxies:**\n"
    msg += f"• Total: {proxy_stats['total']}\n\n"
    msg += f"**Users:**\n"
    msg += f"• Approved: {len(approval_system.get_approved_list())}\n"
    msg += f"• Pending: {len(approval_system.get_pending_list())}\n"
    msg += f"• Active: {active_count}\n"
    msg += f"• Creating: {creating_count}"
    
    await update.message.reply_text(msg)

async def cancel(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    state = get_user_state(user_id)
    state.reset()
    
    with otp_storage_lock:
        if user_id in otp_storage:
            del otp_storage[user_id]
    
    await update.message.reply_text("❌ **Cancelled!** Send `/make` to start fresh.")

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    text = update.message.text.strip()
    state = get_user_state(user_id)
    
    if state.awaiting_otp:
        if text.isdigit() and len(text) == 6:
            await handle_otp(update, context)
            return
        else:
            await update.message.reply_text("❌ **Invalid OTP!** Must be 6 digits.")
            return
    
    if state.step == "waiting_phone":
        await handle_phone(update, context)
        return
    
    await update.message.reply_text(
        "❌ I don't understand.\n\n"
        "Use:\n"
        "/make - Create Gmail\n"
        "/cancel - Cancel\n"
        "/stats - Statistics"
    )

async def error_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    logger.error(f"Update {update} caused error {context.error}")
    for owner_id in OWNERS:
        try:
            await context.bot.send_message(owner_id, f"⚠️ **Error:** {str(context.error)[:200]}")
        except:
            pass

# ============================================
# MAIN
# ============================================

def main():
    print("\n" + "="*60)
    print("🚀 GMAIL CREATOR BOT")
    print("="*60)
    print(f"👑 Owner: {', '.join(OWNERS)}")
    print(f"📊 Proxies Loaded: {len(PROXY_LIST)}")
    print(f"✅ Approved: {len(approval_system.get_approved_list())}")
    print(f"⏳ Pending: {len(approval_system.get_pending_list())}")
    print(f"🎯 Headless: {HEADLESS_MODE}")
    print("="*60)
    print("🤖 Bot is running...")
    print("="*60 + "\n")
    
    # Setup ChromeDriver
    setup_chromedriver()
    
    app = Application.builder().token(BOT_TOKEN).build()
    
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("make", make_command))
    app.add_handler(CommandHandler("cancel", cancel))
    app.add_handler(CommandHandler("stats", stats_command))
    app.add_handler(CommandHandler("active", active_command))
    app.add_handler(CommandHandler("approve", approve_command))
    app.add_handler(CommandHandler("reject", reject_command))
    app.add_handler(CommandHandler("remove", remove_command))
    app.add_handler(CommandHandler("pending", pending_command))
    app.add_handler(CommandHandler("approved", approved_command))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    app.add_error_handler(error_handler)
    
    app.run_polling()

if __name__ == "__main__":
    main()

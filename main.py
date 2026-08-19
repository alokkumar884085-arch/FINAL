# ============================================
# GMAIL BOT - MANUAL CAPTCHA SUPPORT
# ============================================

import asyncio
import random
import re
import time
import json
import logging
import shutil
import os
import threading
from datetime import datetime, timedelta
from typing import Dict, Optional

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

from webdriver_manager.chrome import ChromeDriverManager
import chromedriver_autoinstaller

# ============================================
# CONFIGURATION
# ============================================

BOT_TOKEN = "8879549452:AAHf_mHGAQNMayGTm6FSHfePTrTmFjR5Vec"
OWNERS = ["8785590284"]
MAX_RETRIES = 20
HEADLESS_MODE = True

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
# PROXY LIST (Short but Working)
# ============================================

PROXY_LIST = [
    "http://45.43.64.38:6296", "http://65.111.3.44:3129", "http://8.211.49.86:80",
    "http://103.95.34.186:3128", "http://162.214.74.29:3128", "http://34.94.46.8:80",
    "http://108.161.135.118:80", "http://167.99.124.118:80", "http://8.221.139.222:8080",
    "http://8.221.141.88:5006", "http://8.211.42.167:104", "http://8.211.49.86:3129",
    "http://8.211.51.115:9050", "http://8.211.200.183:1000", "http://8.215.112.214:7777",
    "http://8.219.97.248:80", "http://8.221.138.111:9080", "http://8.221.141.88:8820",
    "http://8.221.141.88:91", "http://8.221.138.111:5060", "http://8.211.42.167:9080",
    "http://8.211.51.115:8081", "http://8.211.51.115:4002", "http://8.210.17.35:1311",
    "http://8.210.17.35:8001", "http://34.81.160.132:80", "http://34.43.46.91:80",
    "http://34.101.184.164:3128", "http://52.34.243.150:8080", "http://65.111.1.201:3129",
    "http://85.214.107.177:80", "http://89.169.37.254:1080", "http://95.211.174.135:3128",
]

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
        self.awaiting_captcha = False
        self.captcha_token = None
        self.dob = None
        self.driver = None
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
            self.awaiting_captcha = False
            self.captcha_token = None
            self.dob = None
            if self.driver:
                try:
                    self.driver.quit()
                except:
                    pass
                self.driver = None

user_sessions: Dict[str, UserState] = {}
user_sessions_lock = threading.Lock()
otp_storage: Dict[str, str] = {}
otp_storage_lock = threading.Lock()

approval_system = ApprovalSystem()
proxy_manager = ProxyManager()
user_semaphore = asyncio.Semaphore(3)

# ============================================
# CHROMEDRIVER SETUP - RAILWAY FIXED
# ============================================

def find_chrome_path() -> Optional[str]:
    """Find Chrome/Chromium path on Railway"""
    chrome_paths = [
        "/usr/bin/chromium",
        "/usr/bin/chromium-browser",
        "/usr/bin/google-chrome",
        "/usr/bin/google-chrome-stable",
        "/usr/bin/chrome",
        "/opt/google/chrome/chrome",
    ]
    for path in chrome_paths:
        if os.path.exists(path):
            logger.info(f"✅ Chrome found: {path}")
            return path
        if shutil.which(path):
            logger.info(f"✅ Chrome found: {path}")
            return path
    return None

def setup_chromedriver():
    try:
        chrome_path = find_chrome_path()
        if chrome_path:
            os.environ["CHROME_BIN"] = chrome_path
            logger.info(f"✅ Chrome binary set to: {chrome_path}")
        chromedriver_autoinstaller.install()
        logger.info("✅ ChromeDriver installed")
        return True
    except Exception as e:
        logger.error(f"❌ ChromeDriver setup failed: {e}")
        return False

# ============================================
# GMAIL BOT - WITH MANUAL CAPTCHA
# ============================================

class GmailBot:
    def __init__(self, proxy: str):
        self.proxy = proxy
        self.driver = None
        self._setup_driver()
    
    def _setup_driver(self):
        options = Options()
        
        chrome_path = find_chrome_path()
        if chrome_path:
            options.binary_location = chrome_path
        
        if self.proxy:
            if self.proxy.startswith(('http://', 'https://', 'socks5://')):
                options.add_argument(f'--proxy-server={self.proxy}')
            else:
                options.add_argument(f'--proxy-server=http://{self.proxy}')
        
        if HEADLESS_MODE:
            options.add_argument("--headless=new")
        
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
        
        try:
            stealth(self.driver,
                    languages=["en-US", "en"],
                    vendor="Google Inc.",
                    platform="Win32",
                    webgl_vendor="Intel Inc.",
                    renderer="Intel Iris OpenGL Engine",
                    fix_hairline=True)
        except:
            pass
        
        self.driver.set_page_load_timeout(30)
    
    def create_account(self, email_prefix: str, password: str, phone: str, otp_callback=None, captcha_callback=None) -> tuple:
        try:
            if not self.driver:
                return (False, None, "Driver not initialized")
            
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
            
            # ========== DOB ==========
            dob = generate_dob()
            month_dropdown = WebDriverWait(self.driver, 20).until(
                EC.element_to_be_clickable((By.ID, "month"))
            )
            month_dropdown.click()
            time.sleep(1)
            for option in self.driver.find_elements(By.XPATH, "//select[@id='month']/option"):
                if option.get_attribute('value') == str(dob['month_int']):
                    option.click()
                    break
            self.driver.find_element(By.ID, "day").send_keys(str(dob['day_int']))
            self.driver.find_element(By.ID, "year").send_keys(str(dob['year_int']))
            
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
                for error in self.driver.find_elements(By.XPATH, "//div[@role='alert']"):
                    if "taken" in error.text.lower() or "already" in error.text.lower():
                        return (False, None, "USERNAME_TAKEN")
            except:
                pass
            
            # ========== PASSWORD ==========
            self.driver.find_element(By.NAME, "Passwd").send_keys(password)
            self.driver.find_element(By.NAME, "PasswdAgain").send_keys(password)
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
            
            # ========== CAPTCHA HANDLING (MANUAL) ==========
            try:
                captcha_elements = self.driver.find_elements(By.XPATH, "//div[@data-sitekey]")
                if captcha_elements:
                    sitekey = captcha_elements[0].get_attribute('data-sitekey')
                    page_url = self.driver.current_url
                    
                    logger.info("🔍 Captcha detected! Waiting for manual solve...")
                    
                    # ✅ User ko captcha solve karne ka link bhejo
                    if captcha_callback:
                        captcha_token = captcha_callback(sitekey, page_url)
                        if captcha_token:
                            self.driver.execute_script(
                                f"document.getElementById('g-recaptcha-response').innerHTML='{captcha_token}';"
                            )
                            time.sleep(2)
                            logger.info("✅ Captcha token injected!")
                        else:
                            return (False, None, "CAPTCHA_TIMEOUT")
            except Exception as e:
                logger.warning(f"⚠️ Captcha handling error: {e}")
            
            # ========== OTP ==========
            if otp_callback:
                otp = otp_callback()
                if not otp:
                    return (False, None, "OTP_TIMEOUT")
                otp_input = WebDriverWait(self.driver, 30).until(
                    EC.presence_of_element_located((By.ID, "code"))
                )
                otp_input.send_keys(otp)
                verify_btn = WebDriverWait(self.driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, "//span[text()='Verify']"))
                )
                verify_btn.click()
                time.sleep(3)
                
                try:
                    for error in self.driver.find_elements(By.XPATH, "//div[@role='alert']"):
                        if "incorrect" in error.text.lower() or "invalid" in error.text.lower():
                            return (False, None, "OTP_INVALID")
                except:
                    pass
            
            # ========== SKIP RECOVERY ==========
            try:
                skip_btn = WebDriverWait(self.driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, "//span[text()='Skip']"))
                )
                skip_btn.click()
                time.sleep(2)
            except:
                pass
            
            # ========== AGREE ==========
            try:
                agree_btn = WebDriverWait(self.driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, "//span[text()='I agree']"))
                )
                agree_btn.click()
                time.sleep(3)
            except:
                pass
            
            return (True, f"{email_prefix}@gmail.com", None)
            
        except Exception as e:
            error_str = str(e)
            if "username" in error_str.lower():
                return (False, None, "USERNAME_TAKEN")
            elif "password" in error_str.lower():
                return (False, None, "PASSWORD_WEAK")
            elif "phone" in error_str.lower():
                return (False, None, "PHONE_INVALID")
            else:
                return (False, None, f"ERROR_{error_str[:50]}")
        finally:
            if self.driver:
                try:
                    self.driver.quit()
                except:
                    pass

# ============================================
# HELPER FUNCTIONS
# ============================================

def get_user_state(user_id: str) -> UserState:
    with user_sessions_lock:
        if user_id not in user_sessions:
            user_sessions[user_id] = UserState(user_id)
        return user_sessions[user_id]

def get_failed_reason(error_code: str) -> str:
    reasons = {
        "USERNAME_TAKEN": "❌ Username already taken! Try different email prefix.",
        "PASSWORD_WEAK": "❌ Password is too weak! Use 8+ chars with letters, numbers, and special characters.",
        "OTP_INVALID": "❌ Invalid OTP! Please check and try again.",
        "OTP_TIMEOUT": "❌ OTP timeout! Please try again.",
        "PHONE_INVALID": "❌ Phone number invalid or already used!",
        "CAPTCHA_TIMEOUT": "❌ Captcha solve timeout! Please try again.",
        "UNKNOWN": "❌ Unknown error! Please try again."
    }
    for key in reasons:
        if key in error_code.upper():
            return reasons[key]
    return f"❌ Error: {error_code[:80]}"

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
            "/captcha YOUR_CODE - Submit manual captcha\n"
            "/cancel - Cancel"
        )
        return
    
    if approval_system.is_approved(user_id):
        await update.message.reply_text(
            "✅ **ACCESS GRANTED**\n\n"
            "/make - Create Gmail\n"
            "/captcha YOUR_CODE - Submit manual captcha\n"
            "/cancel - Cancel\n"
            "/stats - Statistics"
        )
        return
    
    approval_system.request_access(user_id, username)
    for owner_id in OWNERS:
        try:
            await context.bot.send_message(owner_id, f"🔔 New Request\nUser: `{user_id}`\n/approve {user_id}")
        except:
            pass
    await update.message.reply_text("⏳ **Request Sent!** Waiting for owner approval.")

async def make_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    
    if not approval_system.is_approved(user_id):
        await update.message.reply_text("❌ Not approved! Use /start")
        return
    
    if not context.args or len(context.args) < 3:
        await update.message.reply_text(
            "❌ **Wrong Format!**\n\n"
            "Use: `/make name email password`\n"
            "Example: `/make rahul rahul.kumar MyPass@123`"
        )
        return
    
    name, email, password = context.args[0], context.args[1], context.args[2]
    
    if len(email) < 6:
        await update.message.reply_text("❌ Email too short! Min 6 chars.")
        return
    if len(password) < 8:
        await update.message.reply_text("❌ Password too short! Min 8 chars.")
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
        f"🔄 Trying proxies..."
    )
    
    await create_account_with_retry(update, context, msg)

async def captcha_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """User se manual captcha code lena"""
    user_id = str(update.effective_user.id)
    args = context.args
    
    if not args:
        await update.message.reply_text(
            "❌ Please provide the captcha token.\n"
            "Example: `/captcha 03AGdBq26...`"
        )
        return
    
    token = args[0]
    state = get_user_state(user_id)
    
    if not state.awaiting_captcha:
        await update.message.reply_text("❌ No captcha request pending!")
        return
    
    state.captcha_token = token
    state.awaiting_captcha = False
    
    await update.message.reply_text("✅ Captcha token received! Continuing...")

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
            
            await msg.edit_text(f"🔄 **Attempt {state.retry_count}/{MAX_RETRIES}**\n🌐 Using proxy...")
            
            try:
                otp_received = asyncio.Event()
                otp_value = None
                captcha_received = asyncio.Event()
                captcha_value = None
                
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
                    except:
                        return None
                
                async def get_captcha(sitekey, page_url):
                    nonlocal captcha_value
                    state.awaiting_captcha = True
                    captcha_received.clear()
                    
                    # ✅ User ko captcha link bhejo
                    await context.bot.send_message(
                        user_id,
                        f"🔍 **CAPTCHA REQUIRED!**\n\n"
                        f"Sitekey: `{sitekey}`\n"
                        f"Page URL: {page_url}\n\n"
                        f"Please solve the captcha manually:\n"
                        f"1. Open this link: [Google Sign-up](https://accounts.google.com/signup)\n"
                        f"2. Complete the captcha\n"
                        f"3. Submit the token using:\n"
                        f"`/captcha YOUR_TOKEN`\n\n"
                        f"⏳ You have 120 seconds.\n"
                        f"Type `/cancel` to abort"
                    )
                    
                    try:
                        await asyncio.wait_for(captcha_received.wait(), timeout=120)
                        return captcha_value
                    except:
                        return None
                
                bot = GmailBot(proxy)
                result = await asyncio.to_thread(
                    bot.create_account,
                    state.email_prefix,
                    state.password,
                    state.phone,
                    get_otp,
                    get_captcha
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
                    error_code = result[2] if len(result) > 2 else "UNKNOWN"
                    state.last_error = error_code
                    proxy_manager.mark_failed(user_id, proxy)
                    reason = get_failed_reason(error_code)
                    await msg.edit_text(f"❌ Attempt {state.retry_count} failed\n{reason}\n🔄 Trying next proxy...")
                    
            except Exception as e:
                proxy_manager.mark_failed(user_id, proxy)
                await msg.edit_text(f"⚠️ Error: `{str(e)[:80]}`\n🔄 Retrying...")
    
    if not success:
        state.step = "idle"
        final_reason = get_failed_reason(state.last_error or "UNKNOWN")
        await msg.edit_text(
            f"❌ **All attempts failed!**\n\n"
            f"{final_reason}\n\n"
            f"💡 Tips:\n"
            f"• Try a different phone number\n"
            f"• Try a different email prefix\n"
            f"• Make sure password is strong (8+ chars)\n\n"
            f"Try again with `/make`"
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
    if not approval_system.is_owner(str(update.effective_user.id)):
        await update.message.reply_text("❌ Only owner!")
        return
    if not context.args:
        await update.message.reply_text("❌ Usage: `/approve user_id`")
        return
    target_id = context.args[0]
    if approval_system.approve_user(target_id):
        await update.message.reply_text(f"✅ User `{target_id}` approved!")
        try:
            await context.bot.send_message(target_id, "✅ **Approved!** You can now use the bot.")
        except:
            pass
    else:
        await update.message.reply_text(f"❌ User `{target_id}` not pending!")

async def reject_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not approval_system.is_owner(str(update.effective_user.id)):
        await update.message.reply_text("❌ Only owner!")
        return
    if not context.args:
        await update.message.reply_text("❌ Usage: `/reject user_id`")
        return
    target_id = context.args[0]
    if approval_system.reject_user(target_id):
        await update.message.reply_text(f"❌ User `{target_id}` rejected!")
        try:
            await context.bot.send_message(target_id, "❌ **Rejected!** Contact owner.")
        except:
            pass
    else:
        await update.message.reply_text(f"❌ User `{target_id}` not pending!")

async def remove_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not approval_system.is_owner(str(update.effective_user.id)):
        await update.message.reply_text("❌ Only owner!")
        return
    if not context.args:
        await update.message.reply_text("❌ Usage: `/remove user_id`")
        return
    target_id = context.args[0]
    if approval_system.remove_user(target_id):
        await update.message.reply_text(f"✅ User `{target_id}` removed!")
        try:
            await context.bot.send_message(target_id, "❌ **Access revoked!**")
        except:
            pass
    else:
        await update.message.reply_text(f"❌ User `{target_id}` not found!")

async def pending_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not approval_system.is_owner(str(update.effective_user.id)):
        await update.message.reply_text("❌ Only owner!")
        return
    pending = approval_system.get_pending_list()
    if not pending:
        await update.message.reply_text("📭 No pending requests.")
        return
    msg = "📋 **Pending Users**\n\n"
    for uid, data in pending.items():
        msg += f"• `{uid}` - @{data.get('username', 'unknown')}\n"
    await update.message.reply_text(msg)

async def approved_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not approval_system.is_owner(str(update.effective_user.id)):
        await update.message.reply_text("❌ Only owner!")
        return
    approved = approval_system.get_approved_list()
    if not approved:
        await update.message.reply_text("📭 No approved users.")
        return
    msg = "✅ **Approved Users**\n\n"
    for uid, data in approved.items():
        msg += f"• `{uid}` - @{data.get('username', 'unknown')}\n"
    await update.message.reply_text(msg)

async def stats_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = str(update.effective_user.id)
    if not approval_system.is_approved(user_id):
        await update.message.reply_text("❌ Not approved!")
        return
    
    with user_sessions_lock:
        active_count = len(user_sessions)
        creating_count = sum(1 for s in user_sessions.values() if s.step == "creating")
    
    msg = f"📊 **Bot Statistics**\n\n"
    msg += f"**Proxies:** {len(PROXY_LIST)}\n\n"
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
        "/captcha TOKEN - Submit captcha\n"
        "/cancel - Cancel\n"
        "/stats - Statistics"
    )

async def error_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    logger.error(f"Update {update} caused error {context.error}")

# ============================================
# MAIN
# ============================================

def main():
    print("\n" + "="*60)
    print("🚀 GMAIL CREATOR BOT - MANUAL CAPTCHA")
    print("="*60)
    print(f"👑 Owner: {', '.join(OWNERS)}")
    print(f"📊 Proxies: {len(PROXY_LIST)}")
    print(f"🎯 Headless: {HEADLESS_MODE}")
    print("="*60)
    print("🤖 Bot is running...")
    print("📝 Manual Captcha Mode: User will solve captcha manually")
    print("="*60 + "\n")
    
    setup_chromedriver()
    
    application = Application.builder().token(BOT_TOKEN).build()
    
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("make", make_command))
    application.add_handler(CommandHandler("captcha", captcha_command))
    application.add_handler(CommandHandler("cancel", cancel))
    application.add_handler(CommandHandler("stats", stats_command))
    application.add_handler(CommandHandler("approve", approve_command))
    application.add_handler(CommandHandler("reject", reject_command))
    application.add_handler(CommandHandler("remove", remove_command))
    application.add_handler(CommandHandler("pending", pending_command))
    application.add_handler(CommandHandler("approved", approved_command))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    application.add_error_handler(error_handler)
    
    application.run_polling()

if __name__ == "__main__":
    main()

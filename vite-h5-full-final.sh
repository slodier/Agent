#!/bin/bash

# 显示显眼的绿色背景黑色文字标题
echo -e "\033[42;30m 使用 Vite + PNPM + Vue3 创建 H5 项目 \033[0m"

# 提示用户输入项目名称
read -p "请输入项目名称: " PROJECT_NAME

# 显示进度：创建 Vite 项目
echo -e "\033[42;30m [1/7] 正在创建 Vite 项目... \033[0m"
pnpm create vite "$PROJECT_NAME" --template vue <<< ""

# 进入项目目录并安装依赖
echo -e "\033[42;30m [2/7] 进入项目目录并安装依赖... \033[0m"
cd "$PROJECT_NAME" || exit
pnpm install

# 安装必要依赖
echo -e "\033[42;30m [3/7] 安装必要依赖... \033[0m"
pnpm add axios crypto-js postcss-pxtorem sass vue-router vite-plugin-compression

# 安装京东 UI 框架及按需引入插件
echo -e "\033[42;30m [4/7] 安装京东 UI 框架及按需引入插件... \033[0m"
pnpm add @nutui/nutui
pnpm add @nutui/auto-import-resolver unplugin-vue-components -D

# 创建 router 目录和文件
echo -e "\033[42;30m [5/7] 创建 router 文件... \033[0m"
mkdir -p src/router
cat > src/router/index.js <<EOF
import { createRouter, createWebHistory } from 'vue-router';
import routes from './router.js';

const router = createRouter({
  history: createWebHistory(import.meta.env.VITE_BASE || '/'),
  routes
});

export default router;
EOF

cat > src/router/router.js <<EOF
const routes = [
  {
    name: 'Index',
    path: '/',
    component: () => import('@/views/Index.vue')
  }
];

export default routes;
EOF

# 修改 Vite 配置文件
echo -e "\033[42;30m [6/7] 修改 Vite 配置文件... \033[0m"
# 清空并写入 Vite 配置文件
echo 'import { defineConfig, loadEnv } from "vite";' > vite.config.js
echo 'import vue from "@vitejs/plugin-vue";' >> vite.config.js
echo 'import Components from "unplugin-vue-components/vite";' >> vite.config.js
echo 'import NutUIResolver from "@nutui/auto-import-resolver";' >> vite.config.js
echo 'import viteCompression from "vite-plugin-compression"; // 导入 Gzip 插件' >> vite.config.js
echo 'import path from "path";' >> vite.config.js
echo '' >> vite.config.js
echo 'const timestamp = new Date().getTime(); // 生成时间戳' >> vite.config.js
echo '' >> vite.config.js
echo 'export default defineConfig(({ mode }) => {' >> vite.config.js
echo '  const env = loadEnv(mode, process.cwd(), "");' >> vite.config.js
echo '  return {' >> vite.config.js
echo '  base: env.VITE_BASE || "/", ' >> vite.config.js
echo '  build: {' >> vite.config.js
echo '    rollupOptions: {' >> vite.config.js
echo '      output: {' >> vite.config.js
echo "        entryFileNames: \`assets/[name].\${timestamp}.js\`," >> vite.config.js
echo "        chunkFileNames: \`assets/[name].\${timestamp}.js\`," >> vite.config.js
echo "        assetFileNames: \`assets/[name].\${timestamp}[extname]\`," >> vite.config.js
echo '      },' >> vite.config.js
echo '    },' >> vite.config.js
echo '  },' >> vite.config.js
echo '  plugins: [' >> vite.config.js
echo '    vue(),' >> vite.config.js
echo '    Components({' >> vite.config.js
echo '      resolvers: [NutUIResolver()],' >> vite.config.js
echo '    }),' >> vite.config.js
echo '    viteCompression({' >> vite.config.js
echo '      verbose: true,' >> vite.config.js
echo '      disable: false,' >> vite.config.js
echo '      threshold: 10240,' >> vite.config.js
echo '      algorithm: "gzip",' >> vite.config.js
echo '      ext: ".gz",' >> vite.config.js
echo '    }),' >> vite.config.js
echo '  ],' >> vite.config.js
echo '  resolve: {' >> vite.config.js
echo '    alias: {' >> vite.config.js
echo '      "@": path.resolve(__dirname, "./src"),' >> vite.config.js
echo '    },' >> vite.config.js
echo '  },' >> vite.config.js
echo '  };' >> vite.config.js
echo '});' >> vite.config.js

# 添加自适应配置文件
echo -e "\033[42;30m [7/7] 添加前端自适应配置文件... \033[0m"
cat > .postcssrc.cjs <<EOF
module.exports = {
  plugins: {
    'postcss-pxtorem': {
    rootValue: 75, // 设计稿是 375 宽的话就写 37.5；750 就写 75
    propList: ['*'], // 所有属性都转换
    exclude: /node_modules/i, // 忽略所有第三方包
    selectorBlackList: [/^nut-/, '.ignore'], // 不转换 nutui 的类名
  },
  },
};
EOF

# 更新 src/main.js 文件
cat > src/main.js <<EOF
import { createApp } from 'vue';
import './style.css';
import App from './App.vue';
import router from '@/router/index.js';
import '@nutui/nutui/dist/style.css';
// 假设设计稿宽度为750
const baseSize = 75;
function setRem() {
  const scale = document.documentElement.clientWidth / 750;
  document.documentElement.style.fontSize = baseSize * scale + 'px';
}
setRem();
setRem();
window.onresize = setRem;
const app = createApp(App);
app.use(router)
app.mount('#app');

EOF

# 更新 src/App.vue 文件
cat > src/App.vue <<EOF
<template>
  <router-view />
</template>

<script setup lang="ts">
import { onMounted } from 'vue';

onMounted(() => {
  const originalHeight = document.documentElement.clientHeight || document.body.clientHeight;
  window.onresize = () => {
    return (() => {
      const resizeHeight = document.documentElement.clientHeight || document.body.clientHeight;
      if (resizeHeight < originalHeight) {
        document.querySelector('body').setAttribute('style', 'height:' + originalHeight + 'px;');
      } else {
        document.querySelector('body').setAttribute('style', 'height:100%;');
      }
    })();
  };
});
</script>

<style scoped>
</style>
EOF

# 更新 src/style.css 文件
cat > src/style.css <<EOF
* {
  margin: 0;
  padding: 0;
}

body, html {
  width: 100%;
  height: 100%;
}

#app {
  font-family: PingFangSC-Semibold, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  width: 100%;
  height: 100%;
}

.flex-center {
  display: flex;
  align-items: center;
  justify-content: center;
}
EOF

# 创建 views 目录和 Index.vue 文件
mkdir -p src/views
cat > src/views/Index.vue <<EOF
<script lang="ts" setup>
</script>

<template>
  <div class="index-bg"></div>
</template>

<style scoped lang="sass">
</style>
EOF

# 删除 components 目录
rm -rf src/components

# 创建环境变量文件
cat > .env.development <<EOF
NODE_ENV = 'development'
VITE_BASE = '/'
VITE_APP_BASE_API = 'https://jnjmp.litianeb.com/safe-api-nov/'
EOF

cat > .env.production <<EOF
NODE_ENV = 'production'
VITE_BASE = '/xxx/'
VITE_APP_BASE_API = 'https://jnjmp.litianeb.com/safe-api-nov/'
EOF

# 创建 utils 目录和文件
mkdir -p src/utils
cat > src/utils/aes.ts <<EOF
import CryptoJS from 'crypto-js';

const keyStr = "A1x9BkVwQs7LmYzN";

const encrypt = () => {
  const word = timestamp();
  const key = CryptoJS.enc.Utf8.parse(keyStr);
  const srcs = CryptoJS.enc.Utf8.parse(word);
  const encrypted = CryptoJS.AES.encrypt(srcs, key, { mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.Pkcs7 });
  return encrypted.toString();
};

const timestamp = () => {
  return Math.round(new Date().getTime() / 1000).toString();
};

export {
  encrypt
};
EOF

cat > src/utils/axios.ts <<EOF
import CryptoJS from "crypto-js";
import axios, { AxiosRequestConfig, AxiosResponse } from "axios";
import { encrypt } from "./aes";
import {showToast} from "@nutui/nutui";

/**
 * Axios 实例
 */
const request = axios.create({
  baseURL: import.meta.env.VITE_APP_BASE_API,
  timeout: 10000
});

/**
 * 去重表：key 表示同一组 URL+method+参数 的进行中请求
 * 规则：相同 key 的请求在上一个返回之前会被取消（抛出 Cancel with __DUPLICATE__）。
 */
const pendingRequests = new Map<string, boolean>();

/** 判断方法 */
const isGet = (m?: string) => m?.toUpperCase() === 'GET';
const isPost = (m?: string) => m?.toUpperCase() === 'POST';

/**
 * 给请求附加鉴权/防篡改参数（sn、uid）
 */
function attachAuthParams(config: AxiosRequestConfig): void {
  const userId = localStorage.getItem('wwid');

  if (isGet(config.method)) {
    if (!config.params) config.params = {};
    // @ts-ignore
    config.params.sn = encrypt();
    // @ts-ignore
    config.params.uid = userId;
  }

  if (isPost(config.method)) {
    if (!config.data) config.data = {};
    // @ts-ignore
    config.data.sn = encrypt();
    // @ts-ignore
    config.data.uid = userId;
  }
}

/**
 * 合并 GET params 与 POST body，并剔除 sn/uid
 */
function mergedPayload(config: AxiosRequestConfig): Record<string, any> {
  const { sn, uid, ...restParams } = (config.params as Record<string, any>) || {};
  const { sn: sn2, uid: uid2, ...restData } = (config.data as Record<string, any>) || {};
  return { ...restParams, ...restData };
}

/**
 * 生成请求去重用 key：url + method + JSON.stringify(payload) 后 Base64
 */
function buildDedupeKey(config: AxiosRequestConfig): string {
  const url = config.url || '';
  const method = (config.method || '').toUpperCase();
  const payload = mergedPayload(config);
  const raw = url + method + JSON.stringify(payload);
  return CryptoJS.enc.Base64.stringify(CryptoJS.enc.Utf8.parse(raw));
}

/**
 * 在 config 上记录去重 key，便于响应阶段释放
 */
function markDedupeKey(config: AxiosRequestConfig, key: string): void {
  // @ts-ignore
  config.__DEDUPE_KEY__ = key;
}

/** 从响应/错误对象中读取去重 key */
function getDedupeKeyFromConfig(cfg?: AxiosRequestConfig | null): string | undefined {
  // @ts-ignore
  return cfg?.__DEDUPE_KEY__ as string | undefined;
}

/** 根据状态码生成提示信息（如需 UI 层提示可复用） */
function mapStatusToMessage(status?: number): string {
  switch (status) {
    case 401: return 'token过期';
    case 403: return '无权访问';
    case 404: return '请求地址错误';
    case 500: return '服务器出现问题';
    default:  return '无网络';
  }
}

// ===================== 请求拦截 =====================
request.interceptors.request.use(config => {
  // 1) 附加 sn/uid
  attachAuthParams(config);

  // 2) 构建去重 key
  const key = buildDedupeKey(config);
  console.log('dedupe key:', key);

  // 3) 去重：阻止相同 key 的并发
  if (pendingRequests.get(key)) {
    showToast.text('请勿重复提交!')
    return Promise.reject('请勿重复提交!')
  }
  pendingRequests.set(key, true);
  markDedupeKey(config, key);

  return config;
});

// ===================== 响应拦截 =====================
request.interceptors.response.use(
  (response: AxiosResponse) => {
    // 释放去重 key
    const k = getDedupeKeyFromConfig(response.config);
    if (k) pendingRequests.delete(k);

    // 只返回 data，保持现有行为
    return response.data;
  },
  error => {
    // 释放去重 key
    const k = getDedupeKeyFromConfig(error.config);
    if (k) pendingRequests.delete(k);

    // 透传去重类错误
    if (axios.isCancel && axios.isCancel(error) && error.__DUPLICATE__) {
      return Promise.reject(error);
    }

    // 记录并转换提示语（如需要）
    console.log(error);
    const status: number | undefined = error?.response?.status;
    const msg = mapStatusToMessage(status);
    // 这里仅保留原有行为：直接 reject 原错误
    return Promise.reject(error);
  }
);

export default request;

EOF

echo -e "\033[42;30m 项目创建完成！\033[0m"
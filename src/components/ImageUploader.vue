<script setup>
import { ref, computed } from 'vue'
import { supabase } from '../lib/supabase'

const props = defineProps({
  modelValue: { type: String, default: '' },       // image_url
  position: { type: String, default: '50% 50%' }    // image_position, format "X% Y%"
})
const emit = defineEmits(['update:modelValue', 'update:position'])

const uploading = ref(false)
const errorMsg = ref('')
const fileInputRef = ref(null)
const showUrlInput = ref(false)

const previewUrl = computed(() => props.modelValue)
const objectPosition = computed(() => props.position || '50% 50%')

const posX = computed(() => Number(objectPosition.value.split(' ')[0]?.replace('%', '')) || 50)
const posY = computed(() => Number(objectPosition.value.split(' ')[1]?.replace('%', '')) || 50)
const markerStyle = computed(() => ({ left: `${posX.value}%`, top: `${posY.value}%` }))

function setPositionFromSlider(axis, value) {
  const x = axis === 'x' ? value : posX.value
  const y = axis === 'y' ? value : posY.value
  emit('update:position', `${x}% ${y}%`)
}

function triggerFilePicker() {
  fileInputRef.value?.click()
}

async function handleFileChange(e) {
  const file = e.target.files?.[0]
  if (!file) return

  if (!file.type.startsWith('image/')) {
    errorMsg.value = 'File harus berupa gambar (jpg, png, webp, dll).'
    return
  }
  if (file.size > 5 * 1024 * 1024) {
    errorMsg.value = 'Ukuran gambar maksimal 5MB.'
    return
  }

  errorMsg.value = ''
  uploading.value = true
  try {
    const ext = file.name.split('.').pop()
    const fileName = `${crypto.randomUUID()}.${ext}`

    const { error: uploadError } = await supabase.storage
      .from('images')
      .upload(fileName, file, { cacheControl: '3600', upsert: false })

    if (uploadError) throw uploadError

    const { data } = supabase.storage.from('images').getPublicUrl(fileName)
    emit('update:modelValue', data.publicUrl)
    emit('update:position', '50% 50%') // reset titik fokus ke tengah tiap ganti gambar
  } catch (err) {
    errorMsg.value = 'Gagal mengunggah gambar: ' + err.message
  } finally {
    uploading.value = false
    if (fileInputRef.value) fileInputRef.value.value = ''
  }
}

function clearImage() {
  emit('update:modelValue', '')
  emit('update:position', '50% 50%')
}

// --- Drag untuk atur titik fokus (object-position) ---
// Dipakai bareng oleh KEDUA kotak preview, jadi geser di kotak manapun
// sama-sama mengubah satu titik fokus yang sama.
let draggingBox = null

function setFocusFromEvent(box, e) {
  if (!box) return
  const rect = box.getBoundingClientRect()
  const clientX = e.touches ? e.touches[0].clientX : e.clientX
  const clientY = e.touches ? e.touches[0].clientY : e.clientY

  let x = ((clientX - rect.left) / rect.width) * 100
  let y = ((clientY - rect.top) / rect.height) * 100
  x = Math.min(100, Math.max(0, x))
  y = Math.min(100, Math.max(0, y))

  emit('update:position', `${x.toFixed(0)}% ${y.toFixed(0)}%`)
}

function onFocusPointerDown(e) {
  draggingBox = e.currentTarget
  setFocusFromEvent(draggingBox, e)
}
function onFocusPointerMove(e) {
  if (!draggingBox) return
  setFocusFromEvent(draggingBox, e)
}
function onFocusPointerUp() {
  draggingBox = null
}
</script>

<template>
  <div>
    <label class="text-sm font-medium text-gray-700 block mb-1">Gambar</label>

    <template v-if="previewUrl">
      <!-- Preview 1: sama persis rasionya dengan kartu Program/Berita & halaman detail -->
      <p class="text-xs text-gray-500 font-medium mb-1">Tampilan di kartu &amp; halaman detail</p>
      <div
        class="relative w-full aspect-[3/1] rounded-xl overflow-hidden border border-gray-200 mb-3 cursor-crosshair select-none"
        @mousedown="onFocusPointerDown"
        @mousemove="onFocusPointerMove"
        @mouseup="onFocusPointerUp"
        @mouseleave="onFocusPointerUp"
        @touchstart="onFocusPointerDown"
        @touchmove="onFocusPointerMove"
        @touchend="onFocusPointerUp"
      >
        <img :src="previewUrl" class="w-full h-full object-cover pointer-events-none" :style="{ objectPosition }" alt="Preview kartu" draggable="false" />
        <div class="absolute w-5 h-5 rounded-full border-2 border-white bg-forest/70 shadow-md -translate-x-1/2 -translate-y-1/2 pointer-events-none" :style="markerStyle"></div>
      </div>

      <!-- Preview 2: sama persis rasionya dengan carousel di Beranda -->
      <p class="text-xs text-gray-500 font-medium mb-1">Tampilan di carousel Beranda</p>
      <div
        class="relative w-full max-w-xs aspect-[3/2] rounded-xl overflow-hidden border border-gray-200 mb-2 cursor-crosshair select-none"
        @mousedown="onFocusPointerDown"
        @mousemove="onFocusPointerMove"
        @mouseup="onFocusPointerUp"
        @mouseleave="onFocusPointerUp"
        @touchstart="onFocusPointerDown"
        @touchmove="onFocusPointerMove"
        @touchend="onFocusPointerUp"
      >
        <img :src="previewUrl" class="w-full h-full object-cover pointer-events-none" :style="{ objectPosition }" alt="Preview carousel" draggable="false" />
        <div class="absolute w-5 h-5 rounded-full border-2 border-white bg-forest/70 shadow-md -translate-x-1/2 -translate-y-1/2 pointer-events-none" :style="markerStyle"></div>

        <button
          type="button"
          @click.stop="clearImage"
          class="absolute top-2 right-2 bg-white/90 text-red-500 w-8 h-8 rounded-full flex items-center justify-center hover:bg-white shadow-sm"
          title="Hapus gambar"
        >✕</button>
      </div>

      <p class="text-gray-400 text-xs mb-3">
        🎯 Klik atau geser di salah satu preview untuk atur titik fokus — kedua preview otomatis ikut ter-update karena posisinya sama-sama dipakai di dua tempat itu.
      </p>

      <!-- Slider presisi, alternatif kalau drag di gambar terasa kurang akurat -->
      <div class="bg-gray-50 rounded-xl p-4 mb-3 space-y-3">
        <div class="flex items-center gap-3">
          <span class="text-xs text-gray-500 w-20 shrink-0">Horizontal</span>
          <input type="range" min="0" max="100" :value="posX" @input="setPositionFromSlider('x', Number($event.target.value))" class="w-full accent-forest" />
          <span class="text-xs text-gray-400 w-10 text-right shrink-0">{{ posX }}%</span>
        </div>
        <div class="flex items-center gap-3">
          <span class="text-xs text-gray-500 w-20 shrink-0">Vertikal</span>
          <input type="range" min="0" max="100" :value="posY" @input="setPositionFromSlider('y', Number($event.target.value))" class="w-full accent-forest" />
          <span class="text-xs text-gray-400 w-10 text-right shrink-0">{{ posY }}%</span>
        </div>
      </div>
    </template>

    <!-- Tombol upload dari galeri/perangkat -->
    <div class="flex flex-wrap gap-2 items-center">
      <input ref="fileInputRef" type="file" accept="image/*" class="hidden" @change="handleFileChange" />
      <button
        type="button"
        @click="triggerFilePicker"
        :disabled="uploading"
        class="bg-mint text-forest px-4 py-2.5 rounded-xl text-sm font-semibold hover:bg-forest hover:text-white transition-all disabled:opacity-60"
      >
        {{ uploading ? 'Mengunggah...' : (previewUrl ? 'Ganti Gambar' : '📁 Pilih dari Galeri') }}
      </button>

      <button type="button" @click="showUrlInput = !showUrlInput" class="text-gray-400 text-xs underline hover:text-gray-600">
        atau tempel link URL
      </button>
    </div>

    <!-- Input URL manual, disembunyikan secara default -->
    <input
      v-if="showUrlInput"
      :value="modelValue"
      @input="emit('update:modelValue', $event.target.value)"
      type="url"
      placeholder="https://..."
      class="w-full mt-2 px-4 py-3 rounded-xl border border-gray-200 focus:border-leaf focus:ring-2 focus:ring-mint outline-none transition text-sm"
    />

    <p v-if="errorMsg" class="text-red-500 text-xs mt-2">{{ errorMsg }}</p>
    <p class="text-gray-400 text-xs mt-2">Format JPG/PNG/WEBP, maksimal 5MB.</p>
  </div>
</template>
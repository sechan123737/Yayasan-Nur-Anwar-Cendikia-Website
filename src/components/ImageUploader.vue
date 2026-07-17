<script setup>
import { ref, computed } from 'vue'
import { supabase } from '../lib/supabase'

const props = defineProps({
  modelValue: { type: String, default: '' }
})
const emit = defineEmits(['update:modelValue'])

const uploading = ref(false)
const errorMsg = ref('')
const fileInputRef = ref(null)
const showUrlInput = ref(false)

const previewUrl = computed(() => props.modelValue)

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
  } catch (err) {
    errorMsg.value = 'Gagal mengunggah gambar: ' + err.message
  } finally {
    uploading.value = false
    // Reset input supaya bisa pilih file yang sama lagi kalau perlu
    if (fileInputRef.value) fileInputRef.value.value = ''
  }
}

function clearImage() {
  emit('update:modelValue', '')
}
</script>

<template>
  <div>
    <label class="text-sm font-medium text-gray-700 block mb-1">Gambar</label>

    <!-- Preview kalau sudah ada gambar -->
    <div v-if="previewUrl" class="relative w-full h-40 rounded-xl overflow-hidden border border-gray-200 mb-2 group">
      <img :src="previewUrl" class="w-full h-full object-cover" alt="Preview gambar" />
      <button
        type="button"
        @click="clearImage"
        class="absolute top-2 right-2 bg-white/90 text-red-500 w-8 h-8 rounded-full flex items-center justify-center hover:bg-white shadow-sm"
        title="Hapus gambar"
      >✕</button>
    </div>

    <!-- Tombol upload dari galeri/perangkat -->
    <div class="flex flex-wrap gap-2 items-center">
      <input
        ref="fileInputRef"
        type="file"
        accept="image/*"
        class="hidden"
        @change="handleFileChange"
      />
      <button
        type="button"
        @click="triggerFilePicker"
        :disabled="uploading"
        class="bg-mint text-forest px-4 py-2.5 rounded-xl text-sm font-semibold hover:bg-forest hover:text-white transition-all disabled:opacity-60"
      >
        {{ uploading ? 'Mengunggah...' : (previewUrl ? 'Ganti Gambar' : '📁 Pilih dari Galeri') }}
      </button>

      <button
        type="button"
        @click="showUrlInput = !showUrlInput"
        class="text-gray-400 text-xs underline hover:text-gray-600"
      >
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
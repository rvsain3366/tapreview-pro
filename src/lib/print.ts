import html2canvas from 'html2canvas';
import { jsPDF } from 'jspdf';
export async function exportPng(node: HTMLElement, filename: string) { const canvas = await html2canvas(node,{scale:3,backgroundColor:'#ffffff',useCORS:true}); const a=document.createElement('a'); a.download=filename; a.href=canvas.toDataURL('image/png'); a.click(); }
export async function exportPdf(node: HTMLElement, filename: string) { const canvas=await html2canvas(node,{scale:4,backgroundColor:'#ffffff',useCORS:true}); const pdf=new jsPDF({orientation:'landscape',unit:'in',format:[8,6]}); pdf.addImage(canvas.toDataURL('image/png'),'PNG',0,0,8,6); pdf.save(filename); }

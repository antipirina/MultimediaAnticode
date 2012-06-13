package com.anticode.access
{
	/**
	 * Organiza el orden de las secciones dentro de los layerGroups
	 * @author Santiago J. Franzani
	 */
	public class SectionFocusMgr 
	{
		//historial de las secciones que se agregaron por layerGroup (array multidimencional)
		private var sectionsHistory_arr:Array;
		
		//es una lista de todos los layers que se agregaron
		private var layerGroupList_arr:Array;
		
		public function SectionFocusMgr() 
		{
			sectionsHistory_arr = [];
			layerGroupList_arr = [];
		}
		
		/**
		 * Destruye el objeto.
		 */
		public function destroy():void 
		{
			layerGroupList_arr = null;
			sectionsHistory_arr = null;
		}
		
		/**
		 * Agrega la sección indicada a la lista, y devuelve la que debería estar en foco según el stack del layerGroup.
		 * @param	section es la sección que se abre.
		 * @return la sección que focaliza finalmente según el sistema.
		 * 
		 */
		public function openSection(section:Section):Section
		{
			if (section.layerGroup < 0) throw new Error("La sección " + section.sectionID + " no tiene 'layerGroup' configurado.");
			
			//revisa si el layerGroup ya existe en el array
			if (!sectionsHistory_arr[section.layerGroup])
			{
				layerGroupList_arr.push(section.layerGroup);
				layerGroupList_arr.sort(Array.NUMERIC);
				sectionsHistory_arr[section.layerGroup] = [];
			}
			
			//revisa si la sección ya existe en el layerGroup indicado y la posiciona o agrega al frente de su grupo.
			addSection(section);
			
			//hace en cascada una revisión desde el layerGroup más alto para obtener la sección indicada
			var retSection:Section = getFocusedSection();
			return 	retSection;
		}
		

		/**
		 * Agrega una sección al layerGroup indicado si es que no existe. Si ya existe la posiciona al frente de su grupo.
		 * @param	section es la sección que va a agregar.
		 */
		private function addSection(section:Section):void 
		{
			var sectionPosition:int = getSectionPosition(section);

			if (sectionPosition >= 0)
			{
				sectionsHistory_arr[section.layerGroup].splice(sectionPosition, 1);
				sectionsHistory_arr[section.layerGroup].push(section);
				
			}else {
				sectionsHistory_arr[section.layerGroup].push(section);
			}
		}
		
		/**
		 * Hace un recorrido del stack desde el nivel más alto, hasta el más bajo para contrar la sección indicada.
		 * La primera que encuentra es la que seleccionará.
		 * @return section que debe estar focalizada.
		 */
		private function getFocusedSection():Section 
		{
			var currentLayerGroup:int;
			var max:int = layerGroupList_arr.length;
			for (var i:int = 0; i <max ; i++) 
			{
				currentLayerGroup = layerGroupList_arr[layerGroupList_arr.length - i - 1];
				if (sectionsHistory_arr[currentLayerGroup].length > 0)
				{
					return sectionsHistory_arr[currentLayerGroup][sectionsHistory_arr[currentLayerGroup].length-1];
				}
			}
			return null;
		}
		
		
		public function closeSection(section:Section):Section
		{
			
			
			var sectionPosition:int = getSectionPosition(section);

			//se aplicó un parche:
			if (sectionsHistory_arr[section.layerGroup])sectionsHistory_arr[section.layerGroup].splice(sectionPosition, 1);
			
			
			return getFocusedSection();
			
			
/*			var windowsPosition:int = getWindowsDepth(section);
			var max:int = sectionsHistory_arr.length;
			for (var i:int = 0; i < max; i++) 
			{
				if (section == sectionsHistory_arr[i])
				{
					sectionsHistory_arr.splice(windowsPosition, 1);
					
				}
			}*/
		}
		
		/**
		 * Busca el la posición de la sección, dentro del focusGroup.
		 * @param	section
		 * @return int si encuentra la sección, devuelve su posición. Si la sección no existe devuelve -1.
		 */
		private function getSectionPosition(section:Section):int 
		{
			if (!sectionsHistory_arr[section.layerGroup]) return -1;
			var max:int = sectionsHistory_arr[section.layerGroup].length;
			for (var i:int = 0; i < max; i++) 
			{
				if (section == sectionsHistory_arr[section.layerGroup][i])
				{
					return i;
				}
			}	
			return -1;
		}
		
		
		
	}

}
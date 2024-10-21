import { Tooltip, ActionIcon } from '@mantine/core';
import { IconCopy } from '@tabler/icons-react';
import { useState } from 'react';

interface CopyButtonProps {
  text: string;
}

export const CopyButton = ({ text, ...props }: CopyButtonProps) => {
  const [tooltipText, setTooltipText] = useState('Copy to clipboard');
  const handleClick = () => {
    setTooltipText('Copied!');
    navigator.clipboard.writeText(text);
  };

  return (
    <Tooltip label={tooltipText}>
      <ActionIcon variant="transparent" size={16} onClick={handleClick} {...props}>
        <IconCopy />
      </ActionIcon>
    </Tooltip>
  );
};

export default CopyButton;
